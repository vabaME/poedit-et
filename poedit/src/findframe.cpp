/*

    poedit, a wxWindows i18n catalogs editor

    ---------------
      findframe.cpp
    
      Find frame
    
      (c) Vaclav Slavik, 2001

*/


#ifdef __GNUG__
#pragma implementation
#endif

#include <wx/wxprec.h>

#include <wx/xrc/xmlres.h>
#include <wx/config.h>
#include <wx/button.h>
#include <wx/textctrl.h>
#include <wx/listctrl.h>
#include <wx/checkbox.h>

#include "catalog.h"
#include "findframe.h"


BEGIN_EVENT_TABLE(FindFrame, wxDialog)
   EVT_BUTTON(XMLID("find_next"), FindFrame::OnNext)
   EVT_BUTTON(XMLID("find_prev"), FindFrame::OnPrev)
   EVT_BUTTON(wxID_CANCEL, FindFrame::OnCancel)
   EVT_TEXT(XMLID("string_to_find"), FindFrame::OnTextChange)
   EVT_CHECKBOX(-1, FindFrame::OnCheckbox)
   EVT_CLOSE(FindFrame::OnCancel)
END_EVENT_TABLE()

FindFrame::FindFrame(wxWindow *parent, wxListCtrl *list, Catalog *c)
        : m_listCtrl(list), m_catalog(c), m_position(-1)
{
    wxPoint p(wxConfig::Get()->Read(_T("find_pos_x"), -1),
              wxConfig::Get()->Read(_T("find_pos_y"), -1));

    wxTheXmlResource->LoadDialog(this, parent, _T("find_frame"));
    if (p.x != -1) 
        Move(p);
        
    m_btnNext = XMLCTRL(*this, "find_next", wxButton);
    m_btnPrev = XMLCTRL(*this, "find_prev", wxButton);

    XMLCTRL(*this, "in_orig", wxCheckBox)->SetValue(
        wxConfig::Get()->Read(_T("find_in_orig"), (long)true));
    XMLCTRL(*this, "in_trans", wxCheckBox)->SetValue(
        wxConfig::Get()->Read(_T("find_in_trans"), (long)true));
    XMLCTRL(*this, "case_sensitive", wxCheckBox)->SetValue(
        wxConfig::Get()->Read(_T("find_case_sensitive"), (long)false));
}


FindFrame::~FindFrame()
{
    wxConfig::Get()->Write(_T("find_pos_x"), (long)GetPosition().x);
    wxConfig::Get()->Write(_T("find_pos_y"), (long)GetPosition().y);

    wxConfig::Get()->Write(_T("find_in_orig"),
            XMLCTRL(*this, "in_orig", wxCheckBox)->GetValue());
    wxConfig::Get()->Write(_T("find_in_trans"),
                XMLCTRL(*this, "in_trans", wxCheckBox)->GetValue());
    wxConfig::Get()->Write(_T("find_case_sensitive"),
                XMLCTRL(*this, "case_sensitive", wxCheckBox)->GetValue());
}


void FindFrame::Reset(Catalog *c)
{
    m_catalog = c;
    m_position = -1;
    m_btnPrev->Enable(!!m_text);
    m_btnNext->Enable(!!m_text);
}


void FindFrame::OnCancel(wxCommandEvent &event)
{
    Destroy();
}


void FindFrame::OnTextChange(wxCommandEvent &event)
{
    m_text = XMLCTRL(*this, "string_to_find", wxTextCtrl)->GetValue();
    Reset(m_catalog);
}


void FindFrame::OnCheckbox(wxCommandEvent &event)
{
    Reset(m_catalog);
}


void FindFrame::OnPrev(wxCommandEvent &event)
{
    if (!DoFind(-1))
        m_btnPrev->Enable(false);
    else
        m_btnNext->Enable(true);
}


void FindFrame::OnNext(wxCommandEvent &event)
{
    if (!DoFind(+1))
        m_btnNext->Enable(false);
    else
        m_btnPrev->Enable(true);
}


bool FindFrame::DoFind(int dir)
{
    int cnt = m_listCtrl->GetItemCount();
    bool inStr = XMLCTRL(*this, "in_orig", wxCheckBox)->GetValue();
    bool inTrans = XMLCTRL(*this, "in_trans", wxCheckBox)->GetValue();
    bool caseSens = XMLCTRL(*this, "case_sensitive", wxCheckBox)->GetValue();
    int posOrig = m_position;

    bool found = false;
    wxString textc;
    wxString text(m_text);    

    if (!caseSens)
        text.MakeLower();
        
    printf("looking for: '%s'\n", text.c_str());
    
    m_position += dir;
    while (m_position >= 0 && m_position < cnt)
    {
        CatalogData &dt = (*m_catalog)[m_listCtrl->GetItemData(m_position)];
        
        if (inStr)
        {
            #if wxUSE_UNICODE
            textc = dt.GetString();
            #else
            textc = wxString(dt.GetString().wc_str(wxConvUTF8), wxConvLocal);
            #endif
            if (!caseSens)
                textc.MakeLower();
            if (textc.Contains(text)) { found = TRUE; break; }
        }
        if (inTrans)
        {
            #if wxUSE_UNICODE
            textc = dt.GetTranslation();
            #else
            textc = wxString(dt.GetTranslation().wc_str(wxConvUTF8), wxConvLocal);
            #endif
            if (!caseSens)
                textc.MakeLower();

        printf("       is?: '%s'\n", textc.c_str());

            if (textc.Contains(text)) { found = TRUE; break; }
        }

        m_position += dir;
    }

    if (found)
    {
        m_listCtrl->SetItemState(m_position, 
                    wxLIST_STATE_SELECTED, wxLIST_STATE_SELECTED);
        m_listCtrl->EnsureVisible(m_position);
        return true;
    }
    
    m_position = posOrig;
    return false;
}
