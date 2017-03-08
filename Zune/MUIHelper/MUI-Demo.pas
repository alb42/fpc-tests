program MUIDemo;
{ FreePascal Version of
          C Source Code For The MUI Demo Program
          --------------------------------------

             written 1992-95 by Stefan Stuntz

 Even if it doesn't look so, all of the code below is pure C,
 just a little bit enhanced with some MUI specific macros.

 NOTE: This demo shows a few MUI techniques (like Return IDs)
 that are a little outdated. Be sure to also check the other
 demonstration programs for more object oriented GUI design!
}
{$mode objfpc}{$H+}
uses
  {$if defined(MorphOS) or defined(Amiga68k)}
  amigalib,
  {$endif}
  Exec, Utility, intuition, agraphics, AmigaDos, mui, muihelper, gadtools;
const
  LVT_Brian: array[0..45] of PChar = (
    'Cheer up, Brian. You know what they say.',
    'Some things in life are bad,',
    'They can really make you mad.',
    'Other things just make you swear and curse.',
    'When you''re chewing on life''s grissle,',
    'Don''t grumble, give a whistle.',
    'And this''ll help things turn out for the best,',
    'And...',
    '',
    'Always look on the bright side of life',
    'Always look on the light side of life',
    '',
    'If life seems jolly rotten,',
    'There''s something you''ve forgotten,',
    'And that''s to laugh, and smile, and dance, and sing.',
    'When you''re feeling in the dumps,',
    'Don''t be silly chumps,',
    'Just purse your lips and whistle, that''s the thing.',
    'And...',
    '',
    'Always look on the bright side of life, come on!',
    'Always look on the right side of life',
    '',
    'For life is quite absurd,',
    'And death''s the final word.',
    'You must always face the curtain with a bow.',
    'Forget about your sin,',
    'Give the audience a grin.',
    'Enjoy it, it''s your last chance anyhow,',
    'So...',
    '',
    'Always look on the bright side of death',
    'Just before you draw your terminal breath.',
    '',
    'Life''s a piece of shit,',
    'When you look at it.',
    'Life''s a laugh, and death''s a joke, it''s true.',
    'You''ll see it''s all a show,',
    'Keep ''em laughing as you go,',
    'Just remember that the last laugh is on you.',
    'And...',
    '',
    'Always look on the bright side of life !',
    '',
    '...',
    nil
  );

// Convetional GadTools NewMenu structure, a memory
// saving way of definig menus.
  ID_ABOUT  = 1;
  ID_NEWVOL = 2;
  ID_NEWBRI = 3;

  Menu: array[0..4] of TNewMenu = (
    (nm_Type: NM_TITLE;
     nm_Label: 'Project';
     nm_Commkey: nil;
     nm_Flags: 0;
     nm_MutualExclude: 0;
     nm_UserData: nil),

    (nm_Type: NM_ITEM;
     nm_Label: 'About...';
     nm_Commkey: '?';
     nm_Flags: 0;
     nm_MutualExclude: 0;
     nm_UserData: APTR(ID_ABOUT)),

    (nm_Type: NM_ITEM;
     nm_Label: PChar(NM_BARLABEL);
     nm_Commkey: nil;
     nm_Flags: 0;
     nm_MutualExclude: 0;
     nm_UserData: nil),

    (nm_Type: NM_ITEM;
     nm_Label: 'Quit';
     nm_Commkey: 'Q';
     nm_Flags: 0;
     nm_MutualExclude: 0;
     nm_UserData: APTR(MUIV_Application_ReturnID_Quit)),

    (nm_Type: NM_END;
     nm_Label: nil;
     nm_Commkey: nil;
     nm_Flags: 0;
     nm_MutualExclude: 0;
     nm_UserData: nil)
  );

// Here are all the little info texts
// that appear at the top of each demo window.
  IN_Master: PChar = #9'Welcome to the MUI demonstration program. ' +
    'This little toy will show you how easy it is to create graphical user interfaces ' +
    'with MUI and how powerful the results are.'#10#9'MUI is based on BOOPSI, Amiga''s ' +
    'basic object oriented programming system. For details about programming, see the ' +
    '''ReadMe'' file and the documented source code of this demo. Only one thing so far: ' +
    'it''s really easy!'#10#9'Now go on, click around and watch this demo. Or use your ' +
    'keyboard (TAB, Return, Cursor-Keys) if you like that better. Hint: play ' +
    'around with the MUI preferences program and customize every pixel to fit ' +
    'your personal taste.';

  IN_Notify: PChar = #9'MUI objects communicate with each other ' +
    'with the aid of a notifcation system. This system is frequently used in every ' +
    'MUI application. Binding an up and a down arrow to a prop gadget e.g. makes up ' +
    'a scrollbar, binding a scrollbar to a list makes up a listview. You can also ' +
    'bind windows to buttons, thus the window will be opened when the button is ' +
    'pressed.'#10#9'Remember: The main loop of this demo program simply consists of ' +
    'a Wait(). Once set up, MUI handles all user actions concerning the GUI ' +
    'automatically.';

  IN_Frames: PChar = #9'Every MUI object can have a surrounding ' +
    'frame. Several types are available, all adjustable with the preferences program.';

  IN_Images: PChar = #9'MUI offers a vector image class, that allows ' +
    'images to be zoomed to any dimension. Every MUI image is transformed to match the ' +
    'current screens colors before displaying.'#10#9'There are several standard images for ' +
    'often used GUI components (e.g. Arrows). These standard images can be defined via ' +
    'the preferences program.';

  IN_Groups: PChar = #9'Groups are very important for MUI. Their ' +
    'combinations determine how the GUI will look. A group may contain any number of ' +
    'child objects, which are positioned either horizontal or vertical.'#10#9'When a ' +
    'group is layouted, the available space is distributed between all of its ' +
    'children, depending on their minimum and maximum dimensions and on their ' +
    'weight.'#10#9'Of course, the children of a group may be other groups. There ' +
    'are no restrictions.';

  IN_Backfill: PChar = #9'Every object can have its own background, ' +
    'if it wants to. MUI offers several standard backgrounds (e.g. one of the DrawInfo ' +
    'pens or one of the rasters below).'#10'The prefs program allows defining a large number ' +
    'of backgrounds... try it!';

  IN_Listviews: PChar = ''#9'MUI''s list class is very flexible. A list can ' +
    'be made up of any number of columns containing formatted text or even images. Several ' +
    'subclasses of list class (e.g. a directory class and a volume class) are available. ' +
    'All MUI lists have the capability of multi selection, just by setting a single ' +
    'flag.'#10#9'The small info texts at the top of each demo window are made with floattext ' +
    'class. This one just needs a character string as input and formats the text according ' +
    'to its width.';

  IN_Cycle: PChar = #9'Cycle gadgets, radios buttons and simple lists ' +
    'can be used to let the user pick exactly one selection from a list of choices. In this ' +
    'example, all three possibilities are shown. Of course they are connected via notification, ' +
    'so every object will immediately be notified and updated when necessary.';

  IN_String: PChar = #9'Of course, MUI offers a standard string gadget class ' +
    'for text input. The gadget in this example is attached to the list, you can control the ' +
    'list cursor from within the gadget.';

// This are the entries for the cycle gadgets and radio buttons.

  CYA_Computer: array[0..9] of PChar = ('Amiga 500', 'Amiga 600', 'Amiga 1000 :)', 'Amiga 1200', 'Amiga 2000', 'Amiga 3000', 'Amiga 4000', 'Amiga 4000T', 'Atari ST :(', nil );
  CYA_Printer: array[0..3] of PChar = ('HP Deskjet', 'NEC P6', 'Okimate 20', nil);
  CYA_Display: array[0..4] of PChar = ('A1081', 'NEC 3D', 'A2024', 'Eizo T660i', nil);


// Some Macros to make my life easier and the actual source
// code more readable.

function MY_List(fTxt: PChar): PObject_;
begin
  MY_List:= MH_Listview([
    MUIA_Weight, 50,
    MUIA_Listview_Input, MUI_FALSE,
    MUIA_Listview_List, AsTag(MH_Floattext([
      MUIA_Frame, MUIV_Frame_ReadList,
      MUIA_Background, MUII_ReadListBack,
      MUIA_Floattext_Text, AsTag(ftxt),
      MUIA_Floattext_TabSize, 4,
      MUIA_Floattext_Justify, MUI_TRUE,
      TAG_DONE])),
    TAG_DONE]);
end;

function MY_DemoWindow(var Obj: PObject_; Name: PChar; ID: PtrUInt; Info: PChar; const tags: array of PtrUInt; const tags2: array of PtrUInt): PObject_;
begin
  Obj := MH_Window([
    MUIA_Window_Title, AsTag(name),
    MUIA_Window_ID, id,
    WindowContents, AsTag(MH_VGroup([
      Child, AsTag(MY_List(info)),
      TAG_MORE, AsTag(@tags)])),
    TAG_MORE, AsTag(@tags2)]);
  MY_DemoWindow := Obj;
end;

function MY_Image(Nr: PtrUInt): PObject_;
begin
  MY_Image := MH_Image([MUIA_Image_Spec, nr, TAG_DONE]);
end;

function MY_ScaledImage(Nr, x, y, s: PtrInt): PObject_;
begin
  MY_ScaledImage := MH_Image([
    MUIA_Image_Spec, nr,
    MUIA_FixWidth, x,
    MUIA_FixHeight, y,
    MUIA_Image_FreeHoriz, MUI_TRUE,
    MUIA_Image_FreeVert, MUI_TRUE,
    MUIA_Image_State, s,
    TAG_DONE]);
end;

function MY_HProp(var Obj: PObject_): PObject_;
begin
  Obj := MH_Prop([
    MUIA_Frame, PropFrame,
    MUIA_Prop_Horiz, MUI_TRUE,
    MUIA_FixHeight, 8,
    MUIA_Prop_Entries, 111,
    MUIA_Prop_Visible, 10,
    TAG_DONE]);
  MY_HProp := Obj;
end;

function MY_VProp(var Obj: PObject_): PObject_;
begin
  Obj := MH_Prop([
    MUIA_Frame, PropFrame,
    MUIA_Prop_Horiz, MUI_FALSE,
    MUIA_FixWidth, 8,
    MUIA_Prop_Entries, 111,
    MUIA_Prop_Visible, 10,
    TAG_DONE]);
  MY_VProp := Obj;
end;

// For every object we want to refer later (e.g. for notification purposes)
// we need a pointer. These pointers do not need to be static, but this
// saves stack space.


var
  AP_Demo,
  WI_Master,WI_Frames,WI_Images,WI_Notify,WI_Listviews,WI_Groups,WI_Backfill,WI_Cycle,WI_String,
  BT_Notify,BT_Frames,BT_Images,BT_Groups,BT_Backfill,BT_Listviews,BT_Cycle,BT_String,BT_Quit,
  PR_PropA,PR_PropH,PR_PropV,PR_PropL,PR_PropR,PR_PropT,PR_PropB,
  LV_Volumes,LV_Directory,LV_Computer,LV_Brian,
  CY_Computer,CY_Printer,CY_Display,
  MT_Computer,MT_Printer,MT_Display,
  ST_Brian,
  GA_Gauge1,GA_Gauge2,GA_Gauge3: PObject_;

// This is where it all begins...

procedure StartMe;
var
  Running: boolean;
  signals: LongWord;
  Idx: Integer;
  Buf: PtrUInt;
begin
  // Every MUI application needs an application object
  // which will hold general information and serve as
  // a kind of anchor for user input, ARexx functions,
  // commodities interface, etc.
  //
  // An application may have any number of SubWindows
  // which can all be created in the same call or added
  // later, according to your needs.
  //
  // Note that creating a window does not mean to
  // open it, this will be done later by setting
  // the windows open attribute.
  try
    AP_Demo := MH_Application([
      MUIA_Application_Title,       AsTag('MUI-Demo'),
      MUIA_Application_Version,     AsTag('$VER: MUI-Demo 19.6 (12.02.97)'),
      MUIA_Application_Copyright,   AsTag('Copyright ©1992-95, Stefan Stuntz'),
      MUIA_Application_Author,      AsTag('Stefan Stuntz'),
      MUIA_Application_Description, AsTag('Demonstrate the features of MUI.'),
      MUIA_Application_Base,        AsTag('MUIDEMO'),
      MUIA_Application_Menustrip,   AsTag(MUI_MakeObject(MUIO_MenustripNM, [AsTag(@Menu), 0])),

      SubWindow, AsTag(MY_DemoWindow(WI_String, 'String', MAKE_ID('S','T','R','G'), IN_String, [
          Child, AsTag(MH_ListView(LV_Brian, [
            MUIA_Listview_Input, MUI_TRUE,
            MUIA_Listview_List, AsTag(MH_List([MUIA_FRAME, InputListFrame, TAG_DONE])),
            TAG_DONE])),
          Child, AsTag(MH_String(ST_Brian, [MUIA_FRAME, StringFrame, TAG_DONE])),
          TAG_DONE],
        [TAG_DONE])),

      SubWindow, AsTag(MY_DemoWindow(WI_Cycle, 'Cycle Gadgets & RadioButtons', MAKE_ID('C','Y','C','L'), IN_Cycle, [
          Child, AsTag(MH_HGroup([
            Child, AsTag(MH_Radio(MT_Computer, [MUIA_Frame, MUIV_Frame_Group, MUIA_FrameTitle, AsTag('Computer:'), MUIA_Background, MUII_GroupBack, MUIA_Radio_Entries, AsTag(@CYA_Computer), TAG_DONE])),
            Child, AsTag(MH_VGroup([
              Child, AsTag(MH_Radio(MT_Printer, [MUIA_Frame, MUIV_Frame_Group, MUIA_FrameTitle, AsTag('Printer:'), MUIA_Background, MUII_GroupBack, MUIA_Radio_Entries, AsTag(@CYA_Printer), TAG_DONE])),
              Child, AsTag(MH_VSpace(0)),
              Child, AsTag(MH_Radio(MT_Display, [MUIA_Frame, MUIV_Frame_Group, MUIA_FrameTitle, AsTag('Display:'), MUIA_Background, MUII_GroupBack, MUIA_Radio_Entries, AsTag(@CYA_Display), TAG_DONE])),
              TAG_DONE])),
            Child, AsTag(MH_VGroup([
              Child, AsTag(MH_ColGroup(2, [MUIA_Frame, MUIV_Frame_Group, MUIA_FrameTitle, AsTag('Cycle Gadgets'), MUIA_Background, MUII_GroupBack,
                Child, AsTag(MH_Label1('Computer:')), Child, AsTag(MH_Cycle(CY_Computer, [MUIA_Font, AsTag(MUIV_Font_Button), MUIA_Cycle_Entries, AsTag(@CYA_Computer), TAG_DONE])),
                Child, AsTag(MH_Label1('Printer:')), Child, AsTag(MH_Cycle(CY_Printer, [MUIA_Font, AsTag(MUIV_Font_Button), MUIA_Cycle_Entries, AsTag(@CYA_Printer), TAG_DONE])),
                Child, AsTag(MH_Label1('Display:')), Child, AsTag(MH_Cycle(CY_Display, [MUIA_Font, AsTag(MUIV_Font_Button), MUIA_Cycle_Entries, AsTag(@CYA_Display), TAG_DONE])),
                TAG_DONE])),
              Child, AsTag(MH_Listview(LV_Computer, [
                MUIA_Listview_Input, MUI_TRUE,
                MUIA_Listview_List, AsTag(MH_List([MUIA_Frame, InputListFrame, TAG_DONE])),
                TAG_DONE])),
              TAG_DONE])),
            TAG_DONE])),
          TAG_DONE],
        [TAG_DONE])),

      SubWindow, AsTag(MY_DemoWindow(WI_Listviews, 'Listviews', MAKE_ID('L','I','S','T'), IN_Listviews, [
          Child, AsTag(MH_HGroup([MUIA_Frame, MUIV_Frame_Group, MUIA_FrameTitle, AsTag('Dir & Volume List'), MUIA_Background, MUII_GroupBack,
            Child, AsTag(MH_ListView(LV_Directory, [
              MUIA_Listview_Input, MUI_TRUE,
              MUIA_Listview_MultiSelect, MUI_TRUE,
              MUIA_Listview_List, AsTag(MH_DirList([MUIA_FRAME, InputListFrame, MUIA_Dirlist_Directory, AsTag('ram:'), MUIA_List_Title, MUI_TRUE, TAG_DONE])),
              TAG_DONE])),
            Child, AsTag(MH_ListView(LV_Volumes, [
              MUIA_Weight, 20,
              MUIA_Listview_Input, MUI_TRUE,
              MUIA_Listview_List, AsTag(MH_VolumeList([MUIA_FRAME, InputListFrame, MUIA_Dirlist_Directory, AsTag('ram:'), TAG_DONE])),
              TAG_DONE])),
            TAG_DONE])),
          TAG_DONE],
        [TAG_DONE])),

      SubWindow, AsTag(MY_DemoWindow(WI_Notify, 'Notifying', MAKE_ID('B','R','C','A'), IN_Notify, [
          Child, AsTag(MH_HGroup([MUIA_Frame, MUIV_Frame_Group, MUIA_FrameTitle, AsTag('Connections'), MUIA_Background, MUII_GroupBack,
            Child, AsTag(MH_Gauge(GA_Gauge1, [MUIA_Frame, GaugeFrame, MUIA_Gauge_Horiz, MUI_FALSE, MUIA_FixWidth, 16, TAG_DONE])),
            Child, AsTag(MY_VProp(PR_PropL)),
            Child, AsTag(MY_VProp(PR_PropR)),
            Child, AsTag(MH_VGroup([
              Child, AsTag(MH_VSpace(0)),
              Child, AsTag(MY_HProp(PR_PropA)),
              Child, AsTag(MH_HGroup([
                Child, AsTag(MY_HProp(PR_PropH)),
                Child, AsTag(MY_HProp(PR_PropV)),
                TAG_DONE])),
              Child, AsTag(MH_VSpace(0)),
              Child, AsTag(MH_VGroup([
                MUIA_Group_Spacing, 1,
                Child, AsTag(MH_Gauge(GA_Gauge2,[MUIA_FRAME, GaugeFrame, MUIA_Gauge_Horiz, MUI_TRUE, TAG_DONE])),
                Child, AsTag(MH_Scale([MUIA_Scale_Horiz, MUI_TRUE, TAG_DONE])),
                TAG_DONE])),
              Child, AsTag(MH_VSpace(0)),
              TAG_DONE])),
            Child, AsTag(MY_VProp(PR_PropT)),
            Child, AsTag(MY_VProp(PR_PropB)),
            Child, AsTag(MH_Gauge(GA_Gauge3, [MUIA_Frame, GaugeFrame, MUIA_Gauge_Horiz, MUI_FALSE, MUIA_FixWidth, 16, TAG_DONE])),
            TAG_DONE])),
          TAG_DONE],
        [TAG_DONE])),

      SubWindow, AsTag(MY_DemoWindow(WI_Backfill, 'Backfill', MAKE_ID('B','A','C','K'), IN_Backfill, [
          Child, AsTag(MH_VGroup([MUIA_Frame, MUIV_Frame_Group, MUIA_FrameTitle, AsTag('Standard Backgrounds'), MUIA_Background, MUII_GroupBack,
            Child, AsTag(MH_HGroup([
              Child, AsTag(MH_Rectangle(TextFrame, [MUIA_Background, MUII_BACKGROUND, TAG_DONE])),
              Child, AsTag(MH_Rectangle(TextFrame, [MUIA_Background, MUII_FILL, TAG_DONE])),
              Child, AsTag(MH_Rectangle(TextFrame, [MUIA_Background, MUII_SHADOW, TAG_DONE])),
              TAG_DONE])),
            Child, AsTag(MH_HGroup([
              Child, AsTag(MH_Rectangle(TextFrame, [MUIA_Background, MUII_SHADOWBACK, TAG_DONE])),
              Child, AsTag(MH_Rectangle(TextFrame, [MUIA_Background, MUII_SHADOWFILL, TAG_DONE])),
              Child, AsTag(MH_Rectangle(TextFrame, [MUIA_Background, MUII_SHADOWSHINE, TAG_DONE])),
              TAG_DONE])),
            Child, AsTag(MH_HGroup([
              Child, AsTag(MH_Rectangle(TextFrame, [MUIA_Background, MUII_FILLBACK, TAG_DONE])),
              Child, AsTag(MH_Rectangle(TextFrame, [MUIA_Background, MUII_SHINEBACK, TAG_DONE])),
              Child, AsTag(MH_Rectangle(TextFrame, [MUIA_Background, MUII_FILLSHINE, TAG_DONE])),
              TAG_DONE])),
            TAG_DONE])),
          TAG_DONE],
        [TAG_DONE])),

      SubWindow, AsTag(MY_DemoWindow(WI_Groups, 'Groups', MAKE_ID('G','R','P','S'), IN_Groups, [
          Child, AsTag(MH_HGroup([MUIA_Frame, MUIV_Frame_Group, MUIA_FrameTitle, AsTag('Group Types'), MUIA_Background, MUII_GroupBack,
            Child, AsTag(MH_HGroup([MUIA_Frame, MUIV_Frame_Group, MUIA_FrameTitle, AsTag('Horizontal'), MUIA_Background, MUII_GroupBack,
              Child, AsTag(MH_Rectangle(TextFrame, [TAG_DONE])),
              Child, AsTag(MH_Rectangle(TextFrame, [TAG_DONE])),
              Child, AsTag(MH_Rectangle(TextFrame, [TAG_DONE])),
              TAG_DONE])),
            Child, AsTag(MH_VGroup([MUIA_Frame, MUIV_Frame_Group, MUIA_FrameTitle, AsTag('Vertical'), MUIA_Background, MUII_GroupBack,
              Child, AsTag(MH_Rectangle(TextFrame, [TAG_DONE])),
              Child, AsTag(MH_Rectangle(TextFrame, [TAG_DONE])),
              Child, AsTag(MH_Rectangle(TextFrame, [TAG_DONE])),
              TAG_DONE])),
            Child, AsTag(MH_ColGroup(3, [
              Child, AsTag(MH_Rectangle(TextFrame, [TAG_DONE])),
              Child, AsTag(MH_Rectangle(TextFrame, [TAG_DONE])),
              Child, AsTag(MH_Rectangle(TextFrame, [TAG_DONE])),
              Child, AsTag(MH_Rectangle(TextFrame, [TAG_DONE])),
              Child, AsTag(MH_Rectangle(TextFrame, [TAG_DONE])),
              Child, AsTag(MH_Rectangle(TextFrame, [TAG_DONE])),
              Child, AsTag(MH_Rectangle(TextFrame, [TAG_DONE])),
              Child, AsTag(MH_Rectangle(TextFrame, [TAG_DONE])),
              Child, AsTag(MH_Rectangle(TextFrame, [TAG_DONE])),
              TAG_DONE])),
            TAG_DONE])),
          Child, AsTag(MH_HGroup([MUIA_Frame, MUIV_Frame_Group, MUIA_FrameTitle, AsTag('Different Weights'), MUIA_Background, MUII_GroupBack,
            Child, AsTag(MH_Text([MUIA_Frame, TextFrame, MUIA_Background, MUII_TextBack, MUIA_Text_Contents, AsTag(PChar(MUIX_C + '25 kg')),  MUIA_Weight, 25, TAG_DONE])),
            Child, AsTag(MH_Text([MUIA_Frame, TextFrame, MUIA_Background, MUII_TextBack, MUIA_Text_Contents, AsTag(PChar(MUIX_C + '50 kg')) ,  MUIA_Weight,  50, TAG_DONE])),
            Child, AsTag(MH_Text([MUIA_Frame, TextFrame, MUIA_Background, MUII_TextBack, MUIA_Text_Contents, AsTag(PChar(MUIX_C + '75 kg')) ,  MUIA_Weight,  75, TAG_DONE])),
            Child, AsTag(MH_Text([MUIA_Frame, TextFrame, MUIA_Background, MUII_TextBack, MUIA_Text_Contents, AsTag(PChar(MUIX_C + '100 kg')),  MUIA_Weight, 100, TAG_DONE])),
            TAG_DONE])),
          Child, AsTag(MH_HGroup([MUIA_Frame, MUIV_Frame_Group, MUIA_FrameTitle, AsTag('Fixed & Variable Sizes'), MUIA_Background, MUII_GroupBack,
            Child, AsTag(MH_Text([MUIA_Frame, TextFrame, MUIA_Background, MUII_TextBack, MUIA_Text_Contents, AsTag(PChar('fixed')), MUIA_Text_SetMax, MUI_TRUE, TAG_DONE])),
            Child, AsTag(MH_Text([MUIA_Frame, TextFrame, MUIA_Background, MUII_TextBack, MUIA_Text_Contents, AsTag(PChar(MUIX_C + 'free')) , MUIA_Text_SetMax, MUI_FALSE, TAG_DONE])),
            Child, AsTag(MH_Text([MUIA_Frame, TextFrame, MUIA_Background, MUII_TextBack, MUIA_Text_Contents, AsTag(PChar('fixed')) , MUIA_Text_SetMax, MUI_TRUE, TAG_DONE])),
            Child, AsTag(MH_Text([MUIA_Frame, TextFrame, MUIA_Background, MUII_TextBack, MUIA_Text_Contents, AsTag(PChar(MUIX_C + 'free')), MUIA_Text_SetMax, MUI_FALSE, TAG_DONE])),
            Child, AsTag(MH_Text([MUIA_Frame, TextFrame, MUIA_Background, MUII_TextBack, MUIA_Text_Contents, AsTag(PChar('fixed')) , MUIA_Text_SetMax, MUI_TRUE, TAG_DONE])),
            TAG_DONE])),
          TAG_DONE],
        [TAG_DONE])),


      SubWindow, AsTag(MY_DemoWindow(WI_Frames, 'Frames', MAKE_ID('F','R','M','S'), IN_Frames, [
          Child, AsTag(MH_ColGroup(2, [
            Child, AsTag(MH_Text([MUIA_Frame, ButtonFrame     , MUIA_InnerLeft,(2),MUIA_InnerRight,(2),MUIA_InnerTop,(1),MUIA_InnerBottom,(1), MUIA_Background, MUII_TextBack, MUIA_Text_Contents, AsTag(PChar(MUIX_C + 'Button')), TAG_DONE])),
            Child, AsTag(MH_Text([MUIA_Frame, ImageButtonFrame, MUIA_InnerLeft,(2),MUIA_InnerRight,(2),MUIA_InnerTop,(1),MUIA_InnerBottom,(1), MUIA_Background, MUII_TextBack, MUIA_Text_Contents, AsTag(PChar(MUIX_C + 'ImageButton')), TAG_DONE])),
            Child, AsTag(MH_Text([MUIA_Frame, TextFrame       , MUIA_InnerLeft,(2),MUIA_InnerRight,(2),MUIA_InnerTop,(1),MUIA_InnerBottom,(1), MUIA_Background, MUII_TextBack, MUIA_Text_Contents, AsTag(PChar(MUIX_C + 'Text')), TAG_DONE])),
            Child, AsTag(MH_Text([MUIA_Frame, StringFrame     , MUIA_InnerLeft,(2),MUIA_InnerRight,(2),MUIA_InnerTop,(1),MUIA_InnerBottom,(1), MUIA_Background, MUII_TextBack, MUIA_Text_Contents, AsTag(PChar(MUIX_C + 'String')), TAG_DONE])),
            Child, AsTag(MH_Text([MUIA_Frame, ReadListFrame   , MUIA_InnerLeft,(2),MUIA_InnerRight,(2),MUIA_InnerTop,(1),MUIA_InnerBottom,(1), MUIA_Background, MUII_TextBack, MUIA_Text_Contents, AsTag(PChar(MUIX_C + 'ReadList')), TAG_DONE])),
            Child, AsTag(MH_Text([MUIA_Frame, InputListFrame  , MUIA_InnerLeft,(2),MUIA_InnerRight,(2),MUIA_InnerTop,(1),MUIA_InnerBottom,(1), MUIA_Background, MUII_TextBack, MUIA_Text_Contents, AsTag(PChar(MUIX_C + 'InputList')), TAG_DONE])),
            Child, AsTag(MH_Text([MUIA_Frame, PropFrame       , MUIA_InnerLeft,(2),MUIA_InnerRight,(2),MUIA_InnerTop,(1),MUIA_InnerBottom,(1), MUIA_Background, MUII_TextBack, MUIA_Text_Contents, AsTag(PChar(MUIX_C + 'Prop Gadget')), TAG_DONE])),
            Child, AsTag(MH_Text([MUIA_Frame, GroupFrame      , MUIA_InnerLeft,(2),MUIA_InnerRight,(2),MUIA_InnerTop,(1),MUIA_InnerBottom,(1), MUIA_Background, MUII_TextBack, MUIA_Text_Contents, AsTag(PChar(MUIX_C + 'Group')), TAG_DONE])),
            TAG_DONE])),
          TAG_DONE],
        [TAG_DONE])),

      SubWindow, AsTag(MY_DemoWindow(WI_Images, 'Images', MAKE_ID('I','M','G','S'), IN_Images, [
          Child, AsTag(MH_HGroup([
            Child, AsTag(MH_ColGroup(2, [MUIA_Frame, MUIV_Frame_Group, MUIA_FrameTitle, AsTag('Some Images'), MUIA_Background, MUII_GroupBack,
              Child, AsTag(MH_Label('ArrowUp:')),     Child, AsTag(MY_Image(MUII_ArrowUp)),
              Child, AsTag(MH_Label('ArrowDown:')),   Child, AsTag(MY_Image(MUII_ArrowDown)),
              Child, AsTag(MH_Label('ArrowLeft:')),   Child, AsTag(MY_Image(MUII_ArrowLeft)),
              Child, AsTag(MH_Label('ArrowRight:')),  Child, AsTag(MY_Image(MUII_ArrowRight)),
              Child, AsTag(MH_Label('RadioButton:')), Child, AsTag(MY_Image(MUII_RadioButton)),
              Child, AsTag(MH_Label('File:')),        Child, AsTag(MY_Image(MUII_PopFile)),
              Child, AsTag(MH_Label('HardDisk:')),    Child, AsTag(MY_Image(MUII_HardDisk)),
              Child, AsTag(MH_Label('Disk:')),        Child, AsTag(MY_Image(MUII_Disk)),
              Child, AsTag(MH_Label('Chip:')),        Child, AsTag(MY_Image(MUII_Chip)),
              Child, AsTag(MH_Label('Drawer:')),      Child, AsTag(MY_Image(MUII_Drawer)),
              TAG_DONE])),
            Child, AsTag(MH_VGroup([MUIA_Frame, MUIV_Frame_Group, MUIA_FrameTitle, AsTag('Scale Engine'), MUIA_Background, MUII_GroupBack,
              Child, AsTag(MH_VSpace(0)),
              Child, AsTag(MH_HGroup([
                Child, AsTag(MY_ScaledImage(MUII_RadioButton,1,17, 9)),
                Child, AsTag(MY_ScaledImage(MUII_RadioButton,1,20,12)),
                Child, AsTag(MY_ScaledImage(MUII_RadioButton,1,23,15)),
                Child, AsTag(MY_ScaledImage(MUII_RadioButton,1,26,18)),
                Child, AsTag(MY_ScaledImage(MUII_RadioButton,1,29,21)),
                TAG_DONE])),
              Child, AsTag(MH_VSpace(0)),
              Child, AsTag(MH_HGroup([
                Child, AsTag(MY_ScaledImage(MUII_CheckMark,1,13, 7)),
                Child, AsTag(MY_ScaledImage(MUII_CheckMark,1,16,10)),
                Child, AsTag(MY_ScaledImage(MUII_CheckMark,1,19,13)),
                Child, AsTag(MY_ScaledImage(MUII_CheckMark,1,22,16)),
                Child, AsTag(MY_ScaledImage(MUII_CheckMark,1,25,19)),
                Child, AsTag(MY_ScaledImage(MUII_CheckMark,1,28,22)),
                TAG_DONE])),
              Child, AsTag(MH_VSpace(0)),
              Child, AsTag(MH_HGroup([
                Child, AsTag(MY_ScaledImage(MUII_PopFile,0,12,10)),
                Child, AsTag(MY_ScaledImage(MUII_PopFile,0,15,13)),
                Child, AsTag(MY_ScaledImage(MUII_PopFile,0,18,16)),
                Child, AsTag(MY_ScaledImage(MUII_PopFile,0,21,19)),
                Child, AsTag(MY_ScaledImage(MUII_PopFile,0,24,22)),
                Child, AsTag(MY_ScaledImage(MUII_PopFile,0,27,25)),
                TAG_DONE])),
              Child, AsTag(MH_VSpace(0)),
              TAG_DONE])),
            TAG_DONE])),
          TAG_DONE],
        [TAG_DONE])),

    SubWindow,
      AsTag(MH_Window(WI_Master, [
      MUIA_Window_Title, AsTag('MUI-Demo'),
      MUIA_Window_ID, MAKE_ID('M','A','I','N'),
      WindowContents, AsTag(MH_VGroup([
        Child, AsTag(MH_Text([MUIA_Frame, GroupFrame, MUIA_Background, MUII_SHADOWFILL, MUIA_Text_Contents, AsTag(PChar(MUIX_C + MUIX_PH + 'MUI - '+MUIX_B+'M'+MUIX_N+'agic'+MUIX_B+'U'+MUIX_N+'ser'+MUIX_B+'I'+MUIX_N+'nterface'#10'written 1992-95 by Stefan Stuntz')), TAG_DONE])),

        Child, AsTag(MY_List(IN_Master)),

        Child, AsTag(MH_VGroup([MUIA_Frame, MUIV_Frame_Group, MUIA_FrameTitle, AsTag('Available Demos'), MUIA_Background, MUII_GroupBack,
          Child, AsTag(MH_HGroup([MUIA_Group_SameWidth, MUI_TRUE,
            Child, AsTag(MH_SimpleButton(BT_Groups, '_Groups')),
            Child, AsTag(MH_SimpleButton(BT_Frames, '_Frames')),
            Child, AsTag(MH_SimpleButton(BT_Backfill, '_Backfill')),
            TAG_DONE])),
          Child, AsTag(MH_HGroup([MUIA_Group_SameWidth, MUI_TRUE,
            Child, AsTag(MH_SimpleButton(BT_Notify, '_Notify')),
            Child, AsTag(MH_SimpleButton(BT_Listviews, '_Listviews')),
            Child, AsTag(MH_SimpleButton(BT_Cycle, '_Cycle')),
            TAG_DONE])),
          Child, AsTag(MH_HGroup([MUIA_Group_SameWidth, MUI_TRUE,
            Child, AsTag(MH_SimpleButton(BT_Images, '_Images' )),
            Child, AsTag(MH_SimpleButton(BT_String, '_Strings')),
            Child, AsTag(MH_SimpleButton(BT_Quit, '_Quit'   )),
            TAG_DONE])),
          TAG_DONE])),
        TAG_DONE])),
      TAG_DONE])),

    TAG_DONE]);

// See if the application was created. The fail function
// is defined in demos.h, it deletes every created object
// and closes "muimaster.library".
//
// Note that we do not need any
// error control for the sub objects since every error
// will automatically be forwarded to the parent object
// and cause this one to fail too.

    if not Assigned(AP_Demo) then
    begin
      writeln('Failed to create Application');
      Exit;
    end;

// Here comes the notifcation magic. Notifying means:
// When an attribute of an object changes, then please change
// another attribute of another object (accordingly) or send
// a method to another object.

// Lets bind the sub windows to the corresponding button
// of the master window.

    DoMethod(BT_Frames   ,[MUIM_Notify, MUIA_Pressed, MUI_FALSE, AsTag(WI_Frames),    3, MUIM_Set, MUIA_Window_Open, MUI_TRUE]);
    DoMethod(BT_Images   ,[MUIM_Notify, MUIA_Pressed, MUI_FALSE, AsTag(WI_Images),    3, MUIM_Set, MUIA_Window_Open, MUI_TRUE]);
    DoMethod(BT_Notify   ,[MUIM_Notify, MUIA_Pressed, MUI_FALSE, AsTag(WI_Notify),    3, MUIM_Set, MUIA_Window_Open, MUI_TRUE]);
    DoMethod(BT_Listviews,[MUIM_Notify, MUIA_Pressed, MUI_FALSE, AsTag(WI_Listviews), 3, MUIM_Set, MUIA_Window_Open, MUI_TRUE]);
    DoMethod(BT_Groups   ,[MUIM_Notify, MUIA_Pressed, MUI_FALSE, AsTag(WI_Groups),    3, MUIM_Set, MUIA_Window_Open, MUI_TRUE]);
    DoMethod(BT_Backfill ,[MUIM_Notify, MUIA_Pressed, MUI_FALSE, AsTag(WI_Backfill),  3, MUIM_Set, MUIA_Window_Open, MUI_TRUE]);
    DoMethod(BT_Cycle    ,[MUIM_Notify, MUIA_Pressed, MUI_FALSE, AsTag(WI_Cycle),     3, MUIM_Set, MUIA_Window_Open, MUI_TRUE]);
    DoMethod(BT_String   ,[MUIM_Notify, MUIA_Pressed, MUI_FALSE, AsTag(WI_String),    3, MUIM_Set, MUIA_Window_Open, MUI_TRUE]);

    DoMethod(BT_Quit     ,[MUIM_Notify, MUIA_Pressed, MUI_FALSE, AsTag(AP_Demo), 2, MUIM_Application_ReturnID, AsTag(MUIV_Application_ReturnID_Quit)]);

// Automagically remove a window when the user hits the close gadget.

    DoMethod(WI_Images   ,[MUIM_Notify, MUIA_Window_CloseRequest, MUI_TRUE, AsTag(WI_Images   ), 3, MUIM_Set, MUIA_Window_Open, MUI_FALSE]);
    DoMethod(WI_Frames   ,[MUIM_Notify, MUIA_Window_CloseRequest, MUI_TRUE, AsTag(WI_Frames   ), 3, MUIM_Set, MUIA_Window_Open, MUI_FALSE]);
    DoMethod(WI_Notify   ,[MUIM_Notify, MUIA_Window_CloseRequest, MUI_TRUE, AsTag(WI_Notify   ), 3, MUIM_Set, MUIA_Window_Open, MUI_FALSE]);
    DoMethod(WI_Listviews,[MUIM_Notify, MUIA_Window_CloseRequest, MUI_TRUE, AsTag(WI_Listviews), 3, MUIM_Set, MUIA_Window_Open, MUI_FALSE]);
    DoMethod(WI_Groups   ,[MUIM_Notify, MUIA_Window_CloseRequest, MUI_TRUE, AsTag(WI_Groups   ), 3, MUIM_Set, MUIA_Window_Open, MUI_FALSE]);
    DoMethod(WI_Backfill ,[MUIM_Notify, MUIA_Window_CloseRequest, MUI_TRUE, AsTag(WI_Backfill ), 3, MUIM_Set, MUIA_Window_Open, MUI_FALSE]);
    DoMethod(WI_Cycle    ,[MUIM_Notify, MUIA_Window_CloseRequest, MUI_TRUE, AsTag(WI_Cycle    ), 3, MUIM_Set, MUIA_Window_Open, MUI_FALSE]);
    DoMethod(WI_String   ,[MUIM_Notify, MUIA_Window_CloseRequest, MUI_TRUE, AsTag(WI_String   ), 3, MUIM_Set, MUIA_Window_Open, MUI_FALSE]);

// Closing the master window forces a complete shutdown of the application.

    DoMethod(WI_Master, [MUIM_Notify, MUIA_Window_CloseRequest, MUI_TRUE, AsTag(AP_Demo), 2, AsTag(MUIM_Application_ReturnID), AsTag(MUIV_Application_ReturnID_Quit)]);

// This connects the prop gadgets in the notification demo window.

    DoMethod(PR_PropA, [MUIM_Notify, MUIA_Prop_First, MUIV_EveryTime, AsTag(PR_PropH), 3, MUIM_Set, MUIA_Prop_First, MUIV_TriggerValue]);
    DoMethod(PR_PropA, [MUIM_Notify, MUIA_Prop_First, MUIV_EveryTime, AsTag(PR_PropV), 3, MUIM_Set, MUIA_Prop_First, MUIV_TriggerValue]);
    DoMethod(PR_PropH, [MUIM_Notify, MUIA_Prop_First, MUIV_EveryTime, AsTag(PR_PropL), 3, MUIM_Set, MUIA_Prop_First, MUIV_TriggerValue]);
    DoMethod(PR_PropH, [MUIM_Notify, MUIA_Prop_First, MUIV_EveryTime, AsTag(PR_PropR), 3, MUIM_Set, MUIA_Prop_First, MUIV_TriggerValue]);
    DoMethod(PR_PropV, [MUIM_Notify, MUIA_Prop_First, MUIV_EveryTime, AsTag(PR_PropT), 3, MUIM_Set, MUIA_Prop_First, MUIV_TriggerValue]);
    DoMethod(PR_PropV, [MUIM_Notify, MUIA_Prop_First, MUIV_EveryTime, AsTag(PR_PropB), 3, MUIM_Set, MUIA_Prop_First, MUIV_TriggerValue]);

    DoMethod(PR_PropA , [MUIM_Notify, MUIA_Prop_First   , MUIV_EveryTime, AsTag(GA_Gauge2), 3, MUIM_Set, MUIA_Gauge_Current, MUIV_TriggerValue]);
    DoMethod(GA_Gauge2, [MUIM_Notify, MUIA_Gauge_Current, MUIV_EveryTime, AsTag(GA_Gauge1), 3, MUIM_Set, MUIA_Gauge_Current, MUIV_TriggerValue]);
    DoMethod(GA_Gauge2, [MUIM_Notify, MUIA_Gauge_Current, MUIV_EveryTime, AsTag(GA_Gauge3), 3, MUIM_Set, MUIA_Gauge_Current, MUIV_TriggerValue]);

// And here we connect cycle gadgets, radio buttons and the list in the
// cycle & radio window.

    DoMethod(CY_Computer, [MUIM_Notify, MUIA_Cycle_Active, MUIV_EveryTime, AsTag(MT_Computer), 3, MUIM_Set, MUIA_Radio_Active, MUIV_TriggerValue]);
    DoMethod(CY_Printer , [MUIM_Notify, MUIA_Cycle_Active, MUIV_EveryTime, AsTag(MT_Printer ), 3, MUIM_Set, MUIA_Radio_Active, MUIV_TriggerValue]);
    DoMethod(CY_Display , [MUIM_Notify, MUIA_Cycle_Active, MUIV_EveryTime, AsTag(MT_Display ), 3, MUIM_Set, MUIA_Radio_Active, MUIV_TriggerValue]);
    DoMethod(MT_Computer, [MUIM_Notify, MUIA_Radio_Active, MUIV_EveryTime, AsTag(CY_Computer), 3, MUIM_Set, MUIA_Cycle_Active, MUIV_TriggerValue]);
    DoMethod(MT_Printer , [MUIM_Notify, MUIA_Radio_Active, MUIV_EveryTime, AsTag(CY_Printer ), 3, MUIM_Set, MUIA_Cycle_Active, MUIV_TriggerValue]);
    DoMethod(MT_Display , [MUIM_Notify, MUIA_Radio_Active, MUIV_EveryTime, AsTag(CY_Display ), 3, MUIM_Set, MUIA_Cycle_Active, MUIV_TriggerValue]);
    DoMethod(MT_Computer, [MUIM_Notify, MUIA_Radio_Active, MUIV_EveryTime, AsTag(LV_Computer), 3, MUIM_Set, MUIA_List_Active , MUIV_TriggerValue]);
    DoMethod(LV_Computer, [MUIM_Notify, MUIA_List_Active , MUIV_EveryTime, AsTag(MT_Computer), 3, MUIM_Set, MUIA_Radio_Active, MUIV_TriggerValue]);

// This one makes us receive input ids from several list views.

    DoMethod(LV_Volumes, [MUIM_Notify, MUIA_Listview_DoubleClick, MUI_TRUE, AsTag(AP_Demo), 2, MUIM_Application_ReturnID, ID_NEWVOL]);
    DoMethod(LV_Brian, [MUIM_Notify, MUIA_List_Active, MUIV_EveryTime, AsTag(AP_Demo), 2, MUIM_Application_ReturnID, ID_NEWBRI]);

// Set some start values for certain objects.

    DoMethod(LV_Computer, [MUIM_List_Insert, AsTag(@CYA_Computer), AsTag(-1), AsTag(MUIV_List_Insert_Bottom)]);
    DoMethod(LV_Brian, [MUIM_List_Insert, AsTag(@LVT_Brian), AsTag(-1), AsTag(MUIV_List_Insert_Bottom)]);
    MH_set(LV_Computer, MUIA_List_Active, 0);
    MH_set(LV_Brian, MUIA_List_Active, 0);
    MH_set(ST_Brian, MUIA_String_AttachedList, AsTag(LV_Brian));

// Everything's ready, lets launch the application. We will
// open the master window now.

    MH_Set(WI_Master, MUIA_Window_Open, AsTag(True));

// This is the main loop. As you can see, it does just nothing.
// Everything is handled by MUI, no work for the programmer.
//
// The only thing we do here is to react on a double click
// in the volume list (which causes an ID_NEWVOL) by setting
// a new directory name for the directory list. If you want
// to see a real file requester with MUI, wait for the
// next release of MFR :-)

    if MH_Get(WI_Master, MUIA_Window_Open) <> 0 then
    begin
      Running := True;
      while Running do
      begin
        case Integer(DoMethod(AP_Demo, [MUIM_Application_NewInput, AsTag(@signals)])) of
          MUIV_Application_ReturnID_Quit: begin
            Running := False;
          end;

          ID_NEWVOL: begin
            DoMethod(LV_Volumes, [MUIM_List_GetEntry, AsTag(MUIV_List_GetEntry_Active), AsTag(@Buf)]);
            MH_set(LV_Directory, MUIA_Dirlist_Directory, Buf);
          end;

          ID_NEWBRI: begin
            Idx := MH_get(LV_Brian, MUIA_List_Active);
            if (Idx >= 0) and (Idx <= High(LVT_Brian)) then
              MH_Set(ST_Brian,MUIA_String_Contents, AsTag(LVT_Brian[Idx]));
          end;

          ID_ABOUT: begin
            MUI_Request(AP_Demo, WI_Master, 0, nil, 'OK', PChar('MUI-Demo'#10'© 1992-95 by Stefan Stuntz'), [TAG_END]);
          end;
        end;
        if running and (signals <> 0) then
        begin
          signals := Wait(signals or SIGBREAKF_CTRL_C);
          if (signals and SIGBREAKF_CTRL_C) <>0 then
            Break;
        end;
      end;
    end;

    MH_Set(WI_Master, MUIA_Window_Open, AsTag(False));

  finally
    if Assigned(AP_Demo) then
      MUI_DisposeObject(AP_Demo);
  end;
end;

begin
  StartMe;
end.
