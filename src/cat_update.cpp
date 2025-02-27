/*
 *  This file is part of Poedit (https://poedit.net)
 *
 *  Copyright (C) 2000-2023 Vaclav Slavik
 *
 *  Permission is hereby granted, free of charge, to any person obtaining a
 *  copy of this software and associated documentation files (the "Software"),
 *  to deal in the Software without restriction, including without limitation
 *  the rights to use, copy, modify, merge, publish, distribute, sublicense,
 *  and/or sell copies of the Software, and to permit persons to whom the
 *  Software is furnished to do so, subject to the following conditions:
 *
 *  The above copyright notice and this permission notice shall be included in
 *  all copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 *  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 *  DEALINGS IN THE SOFTWARE.
 *
 */

#include "cat_update.h"

#include "errors.h"
#include "extractors/extractor.h"
#include "progressinfo.h"
#include "utility.h"

#include <wx/config.h>
#include <wx/dialog.h>
#include <wx/intl.h>
#include <wx/listbox.h>
#include <wx/log.h>
#include <wx/msgdlg.h>
#include <wx/stattext.h>
#include <wx/xrc/xmlres.h>


namespace
{

/** This class provides simple dialog that displays list
  * of changes made in the catalog.
  */
class MergeSummaryDialog : public wxDialog
{
    public:
        MergeSummaryDialog(wxWindow *parent);
        ~MergeSummaryDialog();

        /** Reads data from catalog and fill dialog's controls.
            \param snew      list of strings that are new to the catalog
            \param sobsolete list of strings that no longer appear in the
                             catalog (as compared to catalog's state before
                             parsing sources).
         */
        void TransferTo(const wxArrayString& snew, 
                        const wxArrayString& sobsolete);
};


MergeSummaryDialog::MergeSummaryDialog(wxWindow *parent)
{
    wxXmlResource::Get()->LoadDialog(this, parent, "summary");

    RestoreWindowState(this, wxDefaultSize, WinState_Size);
    CentreOnParent();
}


MergeSummaryDialog::~MergeSummaryDialog()
{
    SaveWindowState(this, WinState_Size);
}


void MergeSummaryDialog::TransferTo(const wxArrayString& snew, const wxArrayString& sobsolete)
{
    wxString sum;
    sum.Printf(_("(New: %i, obsolete: %i)"),
               (int)snew.GetCount(), (int)sobsolete.GetCount());
    XRCCTRL(*this, "items_count", wxStaticText)->SetLabel(sum);

    wxListBox *listbox;
    size_t i;
    
    listbox = XRCCTRL(*this, "new_strings", wxListBox);
#ifdef __WXOSX__
  #if __MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_16
    if (@available(macOS 11.0, *))
        ((NSTableView*)[((NSScrollView*)listbox->GetHandle()) documentView]).style = NSTableViewStyleFullWidth;
  #endif
#endif

    for (i = 0; i < snew.GetCount(); i++)
    {
        listbox->Append(snew[i]);
    }

    listbox = XRCCTRL(*this, "obsolete_strings", wxListBox);
#ifdef __WXOSX__
  #if __MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_16
    if (@available(macOS 11.0, *))
        ((NSTableView*)[((NSScrollView*)listbox->GetHandle()) documentView]).style = NSTableViewStyleFullWidth;
  #endif
#endif

    for (i = 0; i < sobsolete.GetCount(); i++)
    {
        listbox->Append(sobsolete[i]);
    }
}


inline wxString ItemMergeSummary(const CatalogItemPtr& item)
{
    wxString s = item->GetString();
    if ( item->HasPlural() )
        s += "|" + item->GetPluralString();
    if ( item->HasContext() )
        s += wxString::Format(" [%s]", item->GetContext());

    return s;
}

/** Returns list of strings that are new in reference catalog
    (compared to this one) and that are not present in \a refcat
    (i.e. are obsoleted).

    \see ShowMergeSummary
 */
void GetMergeSummary(CatalogPtr po, CatalogPtr refcat,
                     wxArrayString& snew, wxArrayString& sobsolete)
{
    wxASSERT( snew.empty() );
    wxASSERT( sobsolete.empty() );

    std::set<wxString> strsThis, strsRef;

    for (auto& i: po->items())
        strsThis.insert(ItemMergeSummary(i));
    for (auto& i: refcat->items())
        strsRef.insert(ItemMergeSummary(i));

    for (auto& i: strsThis)
    {
        if (strsRef.find(i) == strsRef.end())
            sobsolete.Add(i);
    }

    for (auto& i: strsRef)
    {
        if (strsThis.find(i) == strsThis.end())
            snew.Add(i);
    }
}

/** Shows a dialog with merge summary.
    \see GetMergeSummary, Merge

    \return true if the merge was OK'ed by the user, false otherwise
 */
bool ShowMergeSummary(wxWindow *parent, CatalogPtr po, CatalogPtr refcat, bool *cancelledByUser)
{
    if (cancelledByUser)
        *cancelledByUser = false;
    if (wxConfig::Get()->ReadBool("show_summary", false))
    {
        wxArrayString snew, sobsolete;
        GetMergeSummary(po, refcat, snew, sobsolete);
        MergeSummaryDialog sdlg(parent);
        sdlg.TransferTo(snew, sobsolete);

        bool ok = (sdlg.ShowModal() == wxID_OK);

        if (cancelledByUser)
            *cancelledByUser = !ok;
        return ok;
    }
    else
        return true;
}

POCatalogPtr ExtractPOTFromSources(POCatalogPtr catalog, UpdateResultReason& reason)
{
    Progress progress(1);

    reason = UpdateResultReason::Unspecified;

    auto spec = catalog->GetSourceCodeSpec();
    if (!spec)
    {
        reason = UpdateResultReason::NoSourcesFound;
        return nullptr;
    }

    progress.message(_(L"Collecting source files…"));

    try
    {
        auto files = Extractor::CollectAllFiles(*spec);

        progress.message(_(L"Extracting translatable strings…"));

        if (!files.empty())
        {
            TempDirectory tmpdir;
            auto potFile = Extractor::ExtractWithAll(tmpdir, *spec, files);
            if (!potFile.empty())
            {
                try
                {
                    return std::make_shared<POCatalog>(potFile, Catalog::CreationFlag_IgnoreHeader);
                }
                catch (...)
                {
                    wxLogError(_("Failed to load file with extracted translations."));
                    reason = UpdateResultReason::Unspecified;
                    return nullptr;
                }
            }
        }
        else
        {
            reason = UpdateResultReason::NoSourcesFound;
            return nullptr;
        }
    }
    catch (ExtractionException& e)
    {
        switch (e.error)
        {
            case ExtractionError::Unspecified:
                reason = UpdateResultReason::Unspecified;
                break;
            case ExtractionError::NoSourcesFound:
                reason = UpdateResultReason::NoSourcesFound;
                break;
            case ExtractionError::PermissionDenied:
                reason = UpdateResultReason::PermissionDenied;
                break;
        }
        reason.file = e.file;
        return nullptr;
    }

    return nullptr;
}

} // anonymous namespace

bool PerformUpdateFromSources(POCatalogPtr catalog, UpdateResultReason& reason)
{
    Progress p(100);

    POCatalogPtr pot;
    {
        Progress subtask(1, p, 90);
        pot = ExtractPOTFromSources(catalog, reason);
        if (!pot)
            return false;
    }
    {
        Progress subtask(1, p, 10);
        subtask.message(_(L"Merging differences…"));
        return catalog->UpdateFromPOT(pot);
    }
}

bool PerformUpdateFromSourcesWithUI(wxWindow *parent,
                                    POCatalogPtr catalog,
                                    UpdateResultReason& reason,
                                    int flags)
{
    const bool skipSummary = (flags & Update_DontShowSummary);

    POCatalogPtr pot;

    bool succ = ProgressWindow::RunCancellableTask(parent, _("Updating translations"),
    [&reason,&pot,catalog](dispatch::cancellation_token_ptr /*cancellationToken*/)
    {
        pot = ExtractPOTFromSources(catalog, reason);
    });

    if (!succ)
    {
        reason = UpdateResultReason::CancelledByUser;
        return false;
    }

    if (!pot)
        return false;

    bool cancelledByUser = false;
    if (skipSummary || ShowMergeSummary(parent, catalog, pot, &cancelledByUser))
    {
        succ = catalog->UpdateFromPOT(pot);
    }

    if (cancelledByUser)
        reason = UpdateResultReason::CancelledByUser;

    return succ;
}


bool PerformUpdateFromPOTWithUI(wxWindow *parent,
                                POCatalogPtr catalog,
                                const wxString& pot_file,
                                UpdateResultReason& reason)
{
    reason = UpdateResultReason::Unspecified;

    try
    {
        auto pot = std::make_shared<POCatalog>(pot_file, Catalog::CreationFlag_IgnoreTranslations);

        // Silently fix duplicates because they are common in WP world:
        if (pot->HasDuplicateItems())
            pot->FixDuplicateItems();

        bool cancelledByUser = false;
        if (ShowMergeSummary(parent, catalog, pot, &cancelledByUser))
        {
            return catalog->UpdateFromPOT(pot);
        }
        else
        {
            if (cancelledByUser)
                reason = UpdateResultReason::CancelledByUser;
            return false;
        }
    }
    catch (...)
    {
        wxMessageDialog dlg
        (
            parent,
            wxString::Format(_(L"The file “%s” couldn’t be opened."), wxFileName(pot_file).GetFullName()),
            _("Invalid file"),
            wxOK | wxICON_ERROR
        );
        dlg.SetExtendedMessage(DescribeCurrentException());
        dlg.ShowModal();
        return false;
    }
}
