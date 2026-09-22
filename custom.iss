
Source: "C:\Users\Zubair\Documents\GitHub\windows-pos\assets\images\yogo-logo.bmp"; DestDir: "{tmp}"; Flags: dontcopy
// **********************
// ***** 1st Design *****
// **********************


[Code]
var
  CustomLabel: TLabel;
  LogoImage: TBitmapImage;

procedure InitializeWizard();
begin
  ExtractTemporaryFile('yogo-logo.bmp');

  WizardForm.ClientWidth  := 700;
  WizardForm.ClientHeight := 550;

  WizardForm.Bevel.Visible           := False;
  WizardForm.BeveledLabel.Visible    := False;
  WizardForm.MainPanel.Color         := $00D2E9FC;
  WizardForm.InnerPage.Color         := $00D2E9FC;
  WizardForm.Color                   := $00D2E9FC;
  WizardForm.PasswordPage.Color      := $00D2E9FC;
end;

procedure CurPageChanged(CurPageID: Integer);
var
  BmpPath: String;
  PageWidth, PageHeight, LogoSize: Integer;
begin
  if CurPageID = wpInstalling then
  begin
    WizardForm.StatusLabel.Visible          := False;
    WizardForm.FilenameLabel.Visible        := False;
    WizardForm.PageNameLabel.Visible        := False;
    WizardForm.PageDescriptionLabel.Visible := False;

    BmpPath    := ExpandConstant('{tmp}\yogo-logo.bmp');
    PageWidth  := WizardForm.InstallingPage.Width;
    PageHeight := WizardForm.InstallingPage.Height;
    LogoSize   := 150;

    if FileExists(BmpPath) then
    begin
      LogoImage := TBitmapImage.Create(WizardForm);
      LogoImage.Parent  := WizardForm.InstallingPage;
      LogoImage.Bitmap.LoadFromFile(BmpPath);
      LogoImage.Width   := LogoSize;
      LogoImage.Height  := LogoSize;
      LogoImage.Stretch := True;
      LogoImage.Left    := (PageWidth - LogoSize) div 2;
      LogoImage.Top     := (PageHeight div 2) - 130;
    end;

    CustomLabel := TLabel.Create(WizardForm);
    CustomLabel.Parent      := WizardForm.InstallingPage;
    CustomLabel.Caption     := 'Installing YOGO POS...';
    CustomLabel.Font.Size   := 14;
    CustomLabel.Font.Style  := [fsBold];
    CustomLabel.Transparent := True;
    CustomLabel.Left        := (PageWidth - CustomLabel.Width) div 2;
    CustomLabel.Top         := (PageHeight div 2) + 30;

    WizardForm.ProgressGauge.Top    := (PageHeight div 2) + 70;
    WizardForm.ProgressGauge.Left   := 60;
    WizardForm.ProgressGauge.Width  := PageWidth - 120;
    WizardForm.ProgressGauge.Height := 20;
  end;
end;

procedure CurInstallProgressChanged(CurProgress, MaxProgress: Integer);
begin
  WizardForm.StatusLabel.Visible   := False;
  WizardForm.FilenameLabel.Visible := False;
end;


// **********************
// ***** 2nd Design *****
// **********************

[Code]

var
  LogoImage   : TBitmapImage;
  TitleLabel  : TLabel;
  SubLabel    : TLabel;

procedure InitializeWizard();
begin
  ExtractTemporaryFile('yogo-logo.bmp');

  WizardForm.ClientWidth  := 620;
  WizardForm.ClientHeight := 440;

  // Default chrome hide
  WizardForm.Bevel.Visible            := False;
  WizardForm.BeveledLabel.Visible     := False;

  // Background color — dark navy
  WizardForm.Color                         := $402519;  // #1a2540
  WizardForm.MainPanel.Color               := $402519;
  WizardForm.InnerPage.Color               := $FFF8F2;  // off-white content area
  WizardForm.WizardBitmapImage.Visible     := False;
  WizardForm.WizardBitmapImage2.Visible    := False;

  // Page title / desc color
  WizardForm.PageNameLabel.Font.Color        := $402519;
  WizardForm.PageNameLabel.Font.Size         := 13;
  WizardForm.PageNameLabel.Font.Style        := [fsBold];
  WizardForm.PageDescriptionLabel.Font.Color := $998070;
  WizardForm.PageDescriptionLabel.Font.Size  := 9;

  // Button styling
  WizardForm.NextButton.Font.Style  := [fsBold];
  WizardForm.BackButton.Font.Style  := [];
  WizardForm.CancelButton.Font.Style:= [];
end;

procedure CurPageChanged(CurPageID: Integer);
var
  BmpPath   : String;
  PW, PH    : Integer;
  LogoSize  : Integer;
begin
  if CurPageID = wpInstalling then
  begin
    // Hide default noisy labels
    WizardForm.StatusLabel.Visible          := False;
    WizardForm.FilenameLabel.Visible        := False;
    WizardForm.PageNameLabel.Visible        := False;
    WizardForm.PageDescriptionLabel.Visible := False;

    PW       := WizardForm.InstallingPage.Width;
    PH       := WizardForm.InstallingPage.Height;
    LogoSize := 100;
    BmpPath  := ExpandConstant('{tmp}\yogo-logo.bmp');

    // Logo
    if FileExists(BmpPath) then
    begin
      LogoImage          := TBitmapImage.Create(WizardForm);
      LogoImage.Parent   := WizardForm.InstallingPage;
      LogoImage.Bitmap.LoadFromFile(BmpPath);
      LogoImage.Width    := LogoSize;
      LogoImage.Height   := LogoSize;
      LogoImage.Stretch  := True;
      LogoImage.Left     := (PW - LogoSize) div 2;
      LogoImage.Top      := (PH div 2) - 140;
    end;

    // Main title
    TitleLabel               := TLabel.Create(WizardForm);
    TitleLabel.Parent        := WizardForm.InstallingPage;
    TitleLabel.Caption       := 'Installing YOGO POS';
    TitleLabel.Font.Size     := 15;
    TitleLabel.Font.Style    := [fsBold];
    TitleLabel.Font.Color    := $402519;   // navy
    TitleLabel.Transparent   := True;
    TitleLabel.AutoSize      := True;
    TitleLabel.Left          := (PW - TitleLabel.Width) div 2;
    TitleLabel.Top           := (PH div 2) - 28;

    // Sub label
    SubLabel                 := TLabel.Create(WizardForm);
    SubLabel.Parent          := WizardForm.InstallingPage;
    SubLabel.Caption         := 'Please wait while files are being copied...';
    SubLabel.Font.Size       := 9;
    SubLabel.Font.Color      := $998070;
    SubLabel.Transparent     := True;
    SubLabel.AutoSize        := True;
    SubLabel.Left            := (PW - SubLabel.Width) div 2;
    SubLabel.Top             := (PH div 2) - 4;

    // Native ProgressGauge — reposition & resize only
    WizardForm.ProgressGauge.Parent  := WizardForm.InstallingPage;
    WizardForm.ProgressGauge.Left    := 40;
    WizardForm.ProgressGauge.Top     := (PH div 2) + 26;
    WizardForm.ProgressGauge.Width   := PW - 80;
    WizardForm.ProgressGauge.Height  := 14;
  end;
end;

procedure CurInstallProgressChanged(CurProgress, MaxProgress: Integer);
begin
  WizardForm.StatusLabel.Visible   := False;
  WizardForm.FilenameLabel.Visible := False;
end;


// **********************
// ***** 3rd Design *****
// **********************
