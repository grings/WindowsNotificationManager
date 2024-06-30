unit FMX.Win.NotificationManager;

interface

uses
  System.SysUtils, System.Classes, FMX.Forms, System.IOUtils,
  System.Generics.Collections, System.DateUtils, System.Win.Registry,

  // Windows RT (Runtime)
  Win.WinRT, Winapi.Winrt, Winapi.Winrt.Utils, Winapi.UI.Notifications,

  // Winapi
  Winapi.Windows, Winapi.Messages, Winapi.CommonTypes, Winapi.Foundation,
  FMX.Win.Notification.Helper;

{$SCOPEDENUMS ON}

type
  TNotification = class;

  TUserInputMap = class;

  TWinBoolean = FMX.Win.Notification.Helper.TWinBoolean;

  // Cardinals
  TSoundEventValue = (          //
    Default,                    //
    NotificationDefault,        //
    NotificationIM,             //
    NotificationMail,           //
    NotificationReminder,       //
    NotificationSMS,            //
    NotificationLoopingAlarm,   //
    NotificationLoopingAlarm2,  //
    NotificationLoopingAlarm3,  //
    NotificationLoopingAlarm4,  //
    NotificationLoopingAlarm5,  //
    NotificationLoopingAlarm6,  //
    NotificationLoopingAlarm7,  //
    NotificationLoopingAlarm8,  //
    NotificationLoopingAlarm9,  //
    NotificationLoopingAlarm10, //
    NotificationLoopingCall,    //
    NotificationLoopingCall2,   //
    NotificationLoopingCall3,   //
    NotificationLoopingCall4,   //
    NotificationLoopingCall5,   //
    NotificationLoopingCall6,   //
    NotificationLoopingCall7,   //
    NotificationLoopingCall8,   //
    NotificationLoopingCall9,   //
    NotificationLoopingCall10); //

  TImagePlacement = (Default, Hero, LogoOverride);

  TImageCrop = (Default, None, Circle);

  TInputType = (Text, Selection);

  TActivationType = (Default, Foreground, Background, Protocol);

  TToastDuration = (// ToastDuration
    Default,        // Use default: short
    Short,          // Show for 7s
    Long);          // Show for 25s

  TAudioMode = (// AudioMode
    Default,    // the notification controls the audio
    Muted,      // no audio
    Custom);    // custom audio overrides all toast sounds

  TNotificationRank = (Default, Normal, High, Topmost);

  TToastScenario = (// ToastScenario
    Default,        // Default notification behaviour
    Alarm,          // Show on screen until the user takes action, NotificationLoopingAlarm selected by default
    Reminder,       // Show on screen until the user takes action
    IncomingCall);  // Show on screen until the user takes action, NotificationLoopingCall selected by default

  TToastDismissReason = ToastDismissalReason;

  // Events
  TOnToastActivated = procedure(Sender: TNotification; Arguments: string; UserInput: TUserInputMap) of object;

  TOnToastDismissed = procedure(Sender: TNotification; Reason: TToastDismissReason) of object;

  TOnToastFailed = procedure(Sender: TNotification; ErrorCode: HRESULT) of object;

  // Record
  TToastComboItem = record
    ID: string;
    Content: string;
  end;

  INotificationEventHandler = interface
    ['{3E0F388D-6B7C-4FE7-A095-3E2822F84EB2}']
    procedure Unscribe;
  end;

  // Events
  TNotificationEventHandler = class(TInspectableObject, INotificationEventHandler)
  private
    FNotification: TNotification;
    FToken: EventRegistrationToken;
  public
    constructor Create(const ANotification: TNotification); virtual;
    procedure Unscribe; virtual; abstract;
    destructor Destroy; override;
  end;

  TNotificationActivatedHandler = class(TNotificationEventHandler, TypedEventHandler_2__IToastNotification__IInspectable, TypedEventHandler_2__IToastNotification__IInspectable_Delegate_Base)
    procedure Invoke(sender: IToastNotification; args: IInspectable); safecall;

    constructor Create(const ANotification: TNotification); override;
    procedure Unscribe; override;
  end;

  TNotificationDismissedHandler = class(TNotificationEventHandler, TypedEventHandler_2__IToastNotification__IToastDismissedEventArgs, TypedEventHandler_2__IToastNotification__IToastDismissedEventArgs_Delegate_Base)
    procedure Invoke(sender: IToastNotification; args: IToastDismissedEventArgs); safecall;

    constructor Create(const ANotification: TNotification); override;
    procedure Unscribe; override;
  end;

  TNotificationFailedHandler = class(TNotificationEventHandler, TypedEventHandler_2__IToastNotification__IToastFailedEventArgs, TypedEventHandler_2__IToastNotification__IToastFailedEventArgs_Delegate_Base)
    procedure Invoke(sender: IToastNotification; args: IToastFailedEventArgs); safecall;

    constructor Create(const ANotification: TNotification); override;
    procedure Unscribe; override;
  end;

  /// Values
  TToastValue = class
  public
    function ToXML: string; virtual; abstract;
  end;

  /// String value
  TToastValueString = class(TToastValue)
  private
    Value: string;
  public
    function ToXML: string; override;

    constructor Create(AValue: string);
  end;

  /// Single value
  TToastValueSingle = class(TToastValue)
  private
    Value: single;
  public
    function ToXML: string; override;

    constructor Create(AValue: single);
  end;

  /// Bindable by ID value
  TToastValueBindable = class(TToastValueString)
    function ToXML: string; override;
  end;

  // Notification data
  TNotificationData = class
  private
    Data: INotificationData;
    function GetValue(Key: string): string;
    procedure SetValue(Key: string; const Value: string);
    function GetSeq: cardinal;
    procedure SetSeq(const Value: cardinal);
  public
    property InterfaceValue: INotificationData read Data;
    // Seq
    property SequenceNumber: cardinal read GetSeq write SetSeq;
    procedure IncreaseSequence;
    // Proc
    procedure Clear;
    function ValueCount: cardinal;
    function ValueExists(Key: string): boolean;
    // Manage
    property Values[Key: string]: string read GetValue write SetValue; default;
    constructor Create;
    destructor Destroy; override;
  end;

  // User input parser
  TUserInputMap = class
  private
    FMap: IMap_2__HSTRING__IInspectable;
  public
    function HasValue(ID: string): boolean;
    function GetStringValue(ID: string): string;
    function GetIntValue(ID: string): integer;

    constructor Create(LookupMap: IMap_2__HSTRING__IInspectable);
    destructor Destroy; override;
  end;

  // Toast notification
  TNotification = class
  private
    FPosted: boolean;
    FToast: IToastNotification;
    FToast2: IToastNotification2;
    FToast3: IToastNotification3;
    FToast4: IToastNotification4;
    FToast6: IToastNotification6;
    FToastScheduled: IScheduledToastNotification;
    FOnActivated: TOnToastActivated;
    FOnDismissed: TOnToastDismissed;
    FOnFailed: TOnToastFailed;
    FHandleActivated: INotificationEventHandler;
    FHandleDismissed: INotificationEventHandler;
    FHandleFailed: INotificationEventHandler;
    FData: TNotificationData;
    procedure FreeEvents;
    procedure Initiate(XML: Xml_Dom_IXmlDocument);
    function GetExpiration: TDateTime;
    procedure SetExpiration(const Value: TDateTime);
    function GetSuppress: boolean;
    procedure SetSuppress(const Value: boolean);
    function GetGroup: string;
    function GetTag: string;
    procedure SetGroup(const Value: string);
    procedure SetTag(const Value: string);
    function GetMirroring: NotificationMirroring;
    procedure SetMirroring(const Value: NotificationMirroring);
    function GetRemoteID: string;
    procedure SetRemoteID(const Value: string);
    procedure SetData(const Value: TNotificationData);
    function GetPriority: ToastNotificationPriority;
    procedure SetPriority(const Value: ToastNotificationPriority);
    function GetExireReboot: boolean;
    procedure SetExpireReboot(const Value: boolean);
    procedure SetEventActivated(const Value: TOnToastActivated);
    procedure SetEventDismissed(const Value: TOnToastDismissed);
    procedure SetEventFailed(const Value: TOnToastFailed);
  public
    // Data read
    property Posted: boolean read FPosted;
    function Content: TXMLInterface;
    ///  <summary>
    ///  Defines the time at which the popup will dissapear.
    ///  </summary>
    property ExpirationTime: TDateTime read GetExpiration write SetExpiration;
    ///  <summary>
    ///  Defines wheather the popup is shown to the user on the
    ///  screen or of It's placed directly in the action center.
    ///  </summary>
    property SuppressPopup: boolean read GetSuppress write SetSuppress;

    // Identifier
    property Tag: string read GetTag write SetTag;
    property Group: string read GetGroup write SetGroup;

    // Remote notification
    property NotificationMirroring: NotificationMirroring read GetMirroring write SetMirroring;
    property RemoteId: string read GetRemoteID write SetRemoteID;

    // Data
    property Data: TNotificationData read FData write SetData;
    property Toast: IToastNotification read FToast;

    // Notification priority
    property Priority: ToastNotificationPriority read GetPriority write SetPriority;

    // Expire notification after reboot
    property ExpiresOnReboot: boolean read GetExireReboot write SetExpireReboot;

    // Events
    property OnActivated: TOnToastActivated read FOnActivated write SetEventActivated;
    property OnDismissed: TOnToastDismissed read FOnDismissed write SetEventDismissed;
    property OnFailed: TOnToastFailed read FOnFailed write SetEventFailed;
    /// <summary>
    ///  Reset the notification to It's default state before being posted.
    /// </summary>
    procedure Reset;
    constructor Create(XMLDocument: TDomXMLDocument);
    destructor Destroy; override;
  end;

  // Builder
  TToastContentBuilder = class
  private
    FXML: TWinXMLDocument;
    FXMLVisual, FXMLBinding, FXMLActions: TWinXMLNode;

    procedure EnsureActions;

    procedure HandleValues(AValues: TArray<TToastValue>);
  public
    function GetXML: TDomXMLDocument;
    // Adders
    procedure AddText(AText: TToastValue);
    (* https://learn.microsoft.com/en-us/uwp/schemas/tiles/toastschema/element-audio *)
    procedure AddAudio(URI: string; Loop: TWinBoolean = TWinBoolean.WinDefault; Silent: TWinBoolean = TWinBoolean.WinDefault); overload;
    procedure AddAudio(CustomSound: TSoundEventValue; Loop: TWinBoolean = TWinBoolean.WinDefault; Silent: TWinBoolean = TWinBoolean.WinDefault); overload;
    (* https://learn.microsoft.com/en-us/uwp/schemas/tiles/toastschema/element-image *)
    procedure AddHeroImage(URI: TToastValue; AltText: string = '');
    procedure AddAppLogoOverride(URI: TToastValue; AdaptiveCrop: TImageCrop; AltText: string = '');
    procedure AddInlineImage(URI: TToastValue; AltText: string = ''; AdaptiveCrop: TImageCrop = TImageCrop.Default; RemoveMargin: boolean = false);
    (* https://learn.microsoft.com/en-us/uwp/schemas/tiles/toastschema/element-progress *)
    procedure AddProgressBar(Title: TToastValue; Value: TToastValue); overload;
    procedure AddProgressBar(Title: TToastValue; Value: TToastValue; Indeterminate: TWinBoolean; ValueStringOverride: TToastValue; Status: TToastValue); overload;
    (* https://learn.microsoft.com/en-us/uwp/schemas/tiles/toastschema/element-input *)
    procedure AddInputTextBox(ID: string; Placeholder: string = ''; Title: string = '');
    procedure AddComboBox(ID: string; Title: string; SelectedItemID: string; Items: TArray<TToastComboItem>);
    (* https://learn.microsoft.com/en-us/uwp/schemas/tiles/toastschema/element-action *)
    procedure AddButton(Content: string; ActivationType: TActivationType; Arguments: string); overload;
    procedure AddButton(Content: string; ActivationType: TActivationType; Arguments, ImageURI: string); overload;
    (* https://learn.microsoft.com/en-us/uwp/schemas/tiles/toastschema/element-header *)
    procedure AddHeader(ID, Title, Arguments: string);
    (* https://learn.microsoft.com/en-us/dotnet/api/microsoft.toolkit.uwp.notifications.toastcontentbuilder.settoastduration *)
    procedure SetToastDuration(Duration: TToastDuration);
    (* https://learn.microsoft.com/en-us/dotnet/api/microsoft.toolkit.uwp.notifications.toastcontent.scenario *)
    procedure SetToastScenario(Scenario: TToastScenario);
    procedure SetBackgroundActivation;
    procedure SetProtocolActivation(URI: string);
    constructor Create;
    destructor Destroy; override;
  end;

  TNotificationManager = class(TObject)
  private
    const
      VALUE_NAME = 'DisplayName';
      VALUE_ICON = 'IconUri';
      VALUE_ACTIVATOR = 'CustomActivator';
      VALUE_SETTINGS = 'ShowInSettings';
      VALUE_LAUNCH = 'LaunchUri';

    var
      FNotifier: IToastNotifier;
      FNotifier2: IToastNotifier2;
      FAppID: string;

      FRegPath: string;
      FRegistry: TRegistry;
      FRegSettingsPath: string;

    procedure RebuildNotifier;
    function HasRegistryRecord: boolean;
    function GetModuleName: string;
    function GetAppIcon: string;
    function GetAppName: string;
    function GetAppLaunch: string;
    function GetAppActivator: string;
    function GetShowSettings: boolean;
    function GetHideLockScreen: TWinBoolean;
    function GetShowBanner: TWinBoolean;
    function GetShowInActionCenter: TWinBoolean;
    function GetRank: TNotificationRank;
    function GetStatusInteractionCount: integer;
    function GetStatusNotificationCount: integer;
    procedure SetAppID(const Value: string);
    procedure SetAppIcon(const Value: string);
    procedure SetAppName(const Value: string);
    procedure SetAppLaunch(const Value: string);
    procedure SetAppActivator(const Value: string);
    procedure SetShowSettings(const Value: boolean);
    procedure SetHideLockScreen(const Value: TWinBoolean);
    procedure SetShowBanner(const Value: TWinBoolean);
    procedure SetShowInActionCenter(const Value: TWinBoolean);
    procedure SetRank(const Value: TNotificationRank);

  public
    // Notificaitons
    procedure ShowNotification(Notification: TNotification);
    procedure HideNotification(Notification: TNotification);
    procedure UpdateNotification(Notification: TNotification);
    // App
    property ApplicationIdentifier: string read FAppID write SetAppID;
    property ApplicationName: string read GetAppName write SetAppName;
    property ApplicationIcon: string read GetAppIcon write SetAppIcon;
    property ApplicationLaunch: string read GetAppLaunch write SetAppLaunch;
    property CustomActivator: string read GetAppActivator write SetAppActivator;
    property ShowInSettings: Boolean read GetShowSettings write SetShowSettings;
    // Action Center Settings
    property HideOnLockScreen: TWinBoolean read GetHideLockScreen write SetHideLockScreen;
    property ShowBanner: TWinBoolean read GetShowBanner write SetShowBanner;
    property ShowInActionCenter: TWinBoolean read GetShowInActionCenter write SetShowInActionCenter;
    property Rank: TNotificationRank read GetRank write SetRank;
    // Status and telemetry
    property TotalNotificationCount: integer read GetStatusNotificationCount;
    property TotalInteractionCount: integer read GetStatusInteractionCount;
    // Utils
    procedure CustomAudioMode(AudioMode: TAudioMode; SoundFilePath: string = '');
    procedure CreateRegistryRecord;
    procedure DeleteRegistryRecord;
    //
    constructor Create; overload;
    constructor Create(ApplicationID: string); overload;
    destructor Destroy; override;
  end;

const
  IID_IToastNotifier2: TGUID = '{354389C6-7C01-4BD5-9C20-604340CD2B74}';
  IID_IToastNotification2: TGUID = '{9DFB9FD1-143A-490E-90BF-B9FBA7132DE7}';
  IID_IToastNotification3: TGUID = '{31E8AED8-8141-4F99-BC0A-C4ED21297D77}';
  IID_IToastNotification4: TGUID = '{15154935-28EA-4727-88E9-C58680E2D118}';
  IID_IToastNotification6: TGUID = '{43EBFE53-89AE-5C1E-A279-3AECFE9B6F54}';
  IID_IScheduledToastNotifier: TGUID = '{79F577F8-0DE7-48CD-9740-9B370490C838}';

function AudioTypeToString(AType: TSoundEventValue): string;

implementation

{ TNotificationAudio }

function AudioTypeToString(AType: TSoundEventValue): string;
begin
  case AType of
    TSoundEventValue.NotificationDefault:
      Result := 'ms-winsoundevent:Notification.Default';
    TSoundEventValue.NotificationIM:
      Result := 'ms-winsoundevent:Notification.IM';
    TSoundEventValue.NotificationMail:
      Result := 'ms-winsoundevent:Notification.Mail';
    TSoundEventValue.NotificationReminder:
      Result := 'ms-winsoundevent:Notification.Reminder';
    TSoundEventValue.NotificationSMS:
      Result := 'ms-winsoundevent:Notification.SMS';
    TSoundEventValue.NotificationLoopingAlarm:
      Result := 'ms-winsoundevent:Notification.Looping.Alarm';
    TSoundEventValue.NotificationLoopingAlarm2:
      Result := 'ms-winsoundevent:Notification.Looping.Alarm2';
    TSoundEventValue.NotificationLoopingAlarm3:
      Result := 'ms-winsoundevent:Notification.Looping.Alarm3';
    TSoundEventValue.NotificationLoopingAlarm4:
      Result := 'ms-winsoundevent:Notification.Looping.Alarm4';
    TSoundEventValue.NotificationLoopingAlarm5:
      Result := 'ms-winsoundevent:Notification.Looping.Alarm5';
    TSoundEventValue.NotificationLoopingAlarm6:
      Result := 'ms-winsoundevent:Notification.Looping.Alarm6';
    TSoundEventValue.NotificationLoopingAlarm7:
      Result := 'ms-winsoundevent:Notification.Looping.Alarm7';
    TSoundEventValue.NotificationLoopingAlarm8:
      Result := 'ms-winsoundevent:Notification.Looping.Alarm8';
    TSoundEventValue.NotificationLoopingAlarm9:
      Result := 'ms-winsoundevent:Notification.Looping.Alarm9';
    TSoundEventValue.NotificationLoopingAlarm10:
      Result := 'ms-winsoundevent:Notification.Looping.Alarm10';
    TSoundEventValue.NotificationLoopingCall:
      Result := 'ms-winsoundevent:Notification.Looping.Call';
    TSoundEventValue.NotificationLoopingCall2:
      Result := 'ms-winsoundevent:Notification.Looping.Call2';
    TSoundEventValue.NotificationLoopingCall3:
      Result := 'ms-winsoundevent:Notification.Looping.Call3';
    TSoundEventValue.NotificationLoopingCall4:
      Result := 'ms-winsoundevent:Notification.Looping.Call4';
    TSoundEventValue.NotificationLoopingCall5:
      Result := 'ms-winsoundevent:Notification.Looping.Call5';
    TSoundEventValue.NotificationLoopingCall6:
      Result := 'ms-winsoundevent:Notification.Looping.Call6';
    TSoundEventValue.NotificationLoopingCall7:
      Result := 'ms-winsoundevent:Notification.Looping.Call7';
    TSoundEventValue.NotificationLoopingCall8:
      Result := 'ms-winsoundevent:Notification.Looping.Call8';
    TSoundEventValue.NotificationLoopingCall9:
      Result := 'ms-winsoundevent:Notification.Looping.Call9';
    TSoundEventValue.NotificationLoopingCall10:
      Result := 'ms-winsoundevent:Notification.Looping.Call10';
  else
    Result := '';
  end;
end;

{ TNotificationManager }

constructor TNotificationManager.Create;
begin
  inherited;
  // Generate default ID
  ApplicationIdentifier := GetModuleName;
  FRegistry := TRegistry.Create(KEY_ALL_ACCESS);
  FRegistry.RootKey := HKEY_CURRENT_USER;
  FRegistry.LazyWrite := False;
end;

constructor TNotificationManager.Create(ApplicationID: string);
begin
  Create;
  SetAppID(ApplicationID);
end;

procedure TNotificationManager.CreateRegistryRecord;
begin
  if not HasRegistryRecord then
  begin
    FRegistry.CreateKey(FRegPath);

    SetAppName(''); // module name
  end;
end;

procedure TNotificationManager.CustomAudioMode(AudioMode: TAudioMode; SoundFilePath: string);
begin
  if not FRegistry.OpenKeyReadOnly(FRegSettingsPath) then
    Exit;

  const VAL = 'SoundFile';
  case AudioMode of
    TAudioMode.Default:
      if FRegistry.ValueExists(VAL) then
        FRegistry.DeleteValue(VAL);
    TAudioMode.Muted:
      FRegistry.WriteString(VAL, '');
    TAudioMode.Custom:
      FRegistry.WriteString(VAL, SoundFilePath);
  end;
end;

procedure TNotificationManager.DeleteRegistryRecord;
begin
  FRegistry.DeleteKey(FRegPath);
end;

destructor TNotificationManager.Destroy;
begin
  FRegistry.Free;
  FNotifier := nil;
  inherited;
end;

function TNotificationManager.GetAppActivator: string;
begin
  Result := '';
  if not FRegistry.OpenKeyReadOnly(FRegPath) then
    Exit;
  if HasRegistryRecord then
    if FRegistry.ValueExists(VALUE_ACTIVATOR) then
      Result := FRegistry.ReadString(VALUE_ACTIVATOR);
end;

function TNotificationManager.GetAppIcon: string;
begin
  Result := '';
  if not FRegistry.OpenKeyReadOnly(FRegPath) then
    Exit;
  if HasRegistryRecord then
    if FRegistry.ValueExists(VALUE_ICON) then
      Result := FRegistry.ReadString(VALUE_ICON);
end;

function TNotificationManager.GetAppLaunch: string;
begin
  Result := '';
  if not FRegistry.OpenKeyReadOnly(FRegPath) then
    Exit;
  if HasRegistryRecord then
    if FRegistry.ValueExists(VALUE_LAUNCH) then
      Result := FRegistry.ReadString(VALUE_LAUNCH);
end;

function TNotificationManager.GetAppName: string;
begin
  Result := '';
  if not FRegistry.OpenKeyReadOnly(FRegPath) then
    Exit;
  if HasRegistryRecord then
    if FRegistry.ValueExists(VALUE_NAME) then
      Result := FRegistry.ReadString(VALUE_NAME);
end;

function TNotificationManager.GetHideLockScreen: TWinBoolean;
begin
  Result := TWinBoolean.WinDefault;
  if not FRegistry.OpenKeyReadOnly(FRegSettingsPath) then
    Exit;
  const VAL = 'AllowContentAboveLock';

  if FRegistry.ValueExists(VAL) then
    Result := WinBool(FRegistry.ReadBool(VAL));
end;

function TNotificationManager.GetModuleName: string;
begin
  Result := ExtractFileName(ParamStr(0));
end;

function TNotificationManager.GetRank: TNotificationRank;
begin
  Result := TNotificationRank.Default;
  if not FRegistry.OpenKeyReadOnly(FRegSettingsPath) then
    Exit;
  const VAL = 'ShowInActionCenter';

  if FRegistry.ValueExists(VAL) then
    case FRegistry.ReadInteger(VAL) of
      0:
        Result := TNotificationRank.Normal;
      1..98:
        Result := TNotificationRank.High;
      99..1000:
        Result := TNotificationRank.Topmost;
    end;
end;

function TNotificationManager.GetShowBanner: TWinBoolean;
begin
  Result := TWinBoolean.WinDefault;
  if not FRegistry.OpenKeyReadOnly(FRegSettingsPath) then
    Exit;
  const VAL = 'ShowBanner';

  if FRegistry.ValueExists(VAL) then
    Result := WinBool(FRegistry.ReadBool(VAL));
end;

function TNotificationManager.GetShowInActionCenter: TWinBoolean;
begin
  Result := TWinBoolean.WinDefault;
  if not FRegistry.OpenKeyReadOnly(FRegSettingsPath) then
    Exit;
  const VAL = 'ShowInActionCenter';

  if FRegistry.ValueExists(VAL) then
    Result := WinBool(FRegistry.ReadBool(VAL));
end;

function TNotificationManager.GetShowSettings: boolean;
begin
  Result := true;
  if not FRegistry.OpenKeyReadOnly(FRegPath) then
    Exit;
  if HasRegistryRecord then
    if FRegistry.ValueExists(VALUE_SETTINGS) then
      Result := FRegistry.ReadInteger(VALUE_SETTINGS) = 1;
end;

function TNotificationManager.GetStatusInteractionCount: integer;
begin
  Result := 0;
  if not FRegistry.OpenKeyReadOnly(FRegSettingsPath) then
    Exit;
  const VAL = 'PeriodicInteractionCount';

  if FRegistry.ValueExists(VAL) then
    Result := FRegistry.ReadInteger(VAL);
end;

function TNotificationManager.GetStatusNotificationCount: integer;
begin
  Result := 0;
  if not FRegistry.OpenKeyReadOnly(FRegSettingsPath) then
    Exit;
  const VAL = 'PeriodicNotificationCount';

  if FRegistry.ValueExists(VAL) then
    Result := FRegistry.ReadInteger(VAL);
end;

function TNotificationManager.HasRegistryRecord: boolean;
begin
  Result := FRegistry.KeyExists(FRegPath);
end;

procedure TNotificationManager.HideNotification(Notification: TNotification);
begin
  if not Notification.Posted then
    raise Exception.Create('Notification is not visible.');

  FNotifier.Hide(Notification.Toast);
end;

procedure TNotificationManager.RebuildNotifier;
var
  AName: HSTRING;
begin
  FNotifier := nil;
  FNotifier2 := nil;

  // Create IToastInterface
  AName := StringToHString(FAppID);
  FNotifier := TToastNotificationManager.CreateToastNotifier(AName);
  FreeHString(AName);

  // Query IToastInterace2
  if Supports(FNotifier, IToastNotifier2, FNotifier2) then
    FNotifier.QueryInterface(IID_IToastNotifier2, FNotifier2);
end;

procedure TNotificationManager.SetAppActivator(const Value: string);
begin
  CreateRegistryRecord;
  if not FRegistry.OpenKey(FRegPath, True) then
    Exit;

  FRegistry.WriteString(VALUE_ACTIVATOR, Value);
end;

procedure TNotificationManager.SetAppIcon(const Value: string);
begin
  CreateRegistryRecord;
  if not FRegistry.OpenKey(FRegPath, True) then
    Exit;

  if Value <> '' then
    FRegistry.WriteString(VALUE_ICON, Value)
  else if FRegistry.ValueExists(VALUE_ICON) then
    FRegistry.DeleteValue(VALUE_ICON);
end;

procedure TNotificationManager.SetAppID(const Value: string);
var
  PreviousPath, PreviousSettingPath: string;
  PreviousRecord: boolean;
begin
  if FAppID = Value then
    Exit;

  // Previous
  PreviousRecord := (FAppID <> '') and HasRegistryRecord;
  PreviousPath := FRegPath;
  PreviousSettingPath := FRegSettingsPath;

  // Set
  FAppID := Value;
  FRegPath := Format('\Software\Classes\AppUserModelId\%S', [FAppID]);
  FRegSettingsPath := Format('\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\%S', [FAppID]);
  RebuildNotifier;

  // Rename App Identifier
  if PreviousRecord then
  begin
    if FRegistry.KeyExists(PreviousPath) then
      FRegistry.MoveKey(PreviousPath, FAppID, True);
    if FRegistry.KeyExists(PreviousSettingPath) then
      FRegistry.MoveKey(PreviousSettingPath, FRegSettingsPath, True);
  end;
end;

procedure TNotificationManager.SetAppLaunch(const Value: string);
begin
  CreateRegistryRecord;
  if not FRegistry.OpenKey(FRegPath, True) then
    Exit;

  if Value <> '' then
    FRegistry.WriteString(VALUE_LAUNCH, Value)
  else if FRegistry.ValueExists(VALUE_LAUNCH) then
    FRegistry.DeleteValue(VALUE_LAUNCH);
end;

procedure TNotificationManager.SetAppName(const Value: string);
begin
  CreateRegistryRecord;
  if not FRegistry.OpenKey(FRegPath, True) then
    Exit;

  if Value <> '' then
    FRegistry.WriteString(VALUE_NAME, Value)
  else
    FRegistry.WriteString(VALUE_NAME, GetModuleName);
end;

procedure TNotificationManager.SetShowBanner(const Value: TWinBoolean);
begin
  const VAL = 'ShowBanner';
  if not FRegistry.OpenKey(FRegSettingsPath, True) then
    Exit;

  if Value <> TWinBoolean.WinDefault then
    FRegistry.WriteBool(VAL, Value.ToBoolean())
  else if FRegistry.ValueExists(VAL) then
    FRegistry.DeleteValue(VAL);
end;

procedure TNotificationManager.SetShowInActionCenter(const Value: TWinBoolean);
begin
  const VAL = 'ShowInActionCenter';
  if not FRegistry.OpenKey(FRegSettingsPath, True) then
    Exit;

  if Value <> TWinBoolean.WinDefault then
    FRegistry.WriteBool(VAL, Value.ToBoolean())
  else if FRegistry.ValueExists(VAL) then
    FRegistry.DeleteValue(VAL);
end;

procedure TNotificationManager.SetShowSettings(const Value: boolean);
begin
  CreateRegistryRecord;
  if not FRegistry.OpenKey(FRegPath, True) then
    Exit;

  if Value = false then
    FRegistry.WriteInteger(VALUE_SETTINGS, 0)
  else if FRegistry.ValueExists(VALUE_SETTINGS) then
    FRegistry.DeleteValue(VALUE_SETTINGS);
end;

procedure TNotificationManager.SetHideLockScreen(const Value: TWinBoolean);
begin
  const VAL = 'AllowContentAboveLock';
  if not FRegistry.OpenKey(FRegSettingsPath, True) then
    Exit;

  if Value <> TWinBoolean.WinDefault then
    FRegistry.WriteBool(VAL, Value.ToBoolean())
  else if FRegistry.ValueExists(VAL) then
    FRegistry.DeleteValue(VAL);
end;

procedure TNotificationManager.SetRank(const Value: TNotificationRank);
begin
  const VAL = 'ShowInActionCenter';
  if not FRegistry.OpenKey(FRegSettingsPath, True) then
    Exit;

  case Value of
    TNotificationRank.Default:
      if FRegistry.ValueExists(VAL) then
        FRegistry.DeleteValue(VAL);
    TNotificationRank.Normal:
      FRegistry.WriteInteger(VAL, 0);
    TNotificationRank.High:
      FRegistry.WriteInteger(VAL, 1);
    TNotificationRank.Topmost:
      FRegistry.WriteInteger(VAL, 99);
  end;
end;

procedure TNotificationManager.ShowNotification(Notification: TNotification);
begin
  if Notification.Posted then
    raise Exception.Create('Notification has already been posted.');

  // Register
  if not HasRegistryRecord then
    CreateRegistryRecord;

  // Show
  FNotifier.Show(Notification.Toast);

  // Status
  Notification.FPosted := True;
end;

procedure TNotificationManager.UpdateNotification(Notification: TNotification);
var
  Data: TNotificationData;
  HS_Tag, HS_Group: HSTRING;
begin
  if not Notification.Posted then
    raise Exception.Create('Notification is not active.');

  if Notification.Tag = '' then
    raise Exception.Create('Tag is required to update notification.');

  // Get data
  Data := Notification.Data;

  // Update
  HS_Tag := StringToHString(Notification.Tag);
  HS_Group := StringToHString(Notification.Group);

  try
    var Result: NotificationUpdateResult;
    if Notification.Group = '' then
      Result := FNotifier2.Update(Data.Data, HS_Tag)
    else
      Result := FNotifier2.Update(Data.Data, HS_Tag, HS_Group);

    if Result <> NotificationUpdateResult.Succeeded then
      raise Exception.CreateFmt('Update procedure or IToastNotifier2 failed, with a result of: %D', [integer(Result)]);
  finally
    FreeHString(HS_Tag);
    FreeHString(HS_Group);
  end;
end;

{ TNotificationActivatedHandler }

constructor TNotificationActivatedHandler.Create(const ANotification: TNotification);
begin
  inherited;
  FToken := FNotification.Toast.add_Activated(Self);
end;

procedure TNotificationActivatedHandler.Invoke(sender: IToastNotification; args: IInspectable);
begin
  const Data = args as IToastActivatedEventArgs;
  const Data2 = args as IToastActivatedEventArgs2;

  const Map = TUserInputMap.Create(Data2.UserInput as IMap_2__HSTRING__IInspectable);
  try
    FNotification.FOnActivated(FNotification, Data.Arguments.ToString, Map);
  finally
    // Free instance
    Map.Free;
  end;
end;

procedure TNotificationActivatedHandler.Unscribe;
begin
  FNotification.Toast.remove_Activated(FToken);
end;

{ TNotificationDismissedHandler }

constructor TNotificationDismissedHandler.Create(const ANotification: TNotification);
begin
  inherited;
  FToken := FNotification.Toast.add_Dismissed(Self);
end;

procedure TNotificationDismissedHandler.Invoke(sender: IToastNotification; args: IToastDismissedEventArgs);
begin
  FNotification.FOnDismissed(FNotification, args.Reason);
end;

procedure TNotificationDismissedHandler.Unscribe;
begin
  FNotification.Toast.remove_Dismissed(FToken);
end;

{ TNotificationFailedHandler }

constructor TNotificationFailedHandler.Create(const ANotification: TNotification);
begin
  inherited;
  FToken := FNotification.Toast.add_Failed(Self);
end;

procedure TNotificationFailedHandler.Invoke(sender: IToastNotification; args: IToastFailedEventArgs);
begin
  FNotification.FOnFailed(FNotification, args.ErrorCode);
end;

procedure TNotificationFailedHandler.Unscribe;
begin
  FNotification.Toast.remove_Failed(FToken);
end;

{ TToastStringValue }

constructor TToastValueString.Create(AValue: string);
begin
  Value := AValue;
end;

function TToastValueString.ToXML: string;
begin
  Result := Value;
end;

{ TNotificationBindableValue }

function TToastValueBindable.ToXML: string;
begin
  Result := Format('{%S}', [Value]);
end;

{ TToastContentBuilder }

procedure TToastContentBuilder.AddAudio(URI: string; Loop, Silent: TWinBoolean);
begin
  with FXML.Nodes.AddNode('audio') do
  begin
    Attributes['src'] := URI;

    if Loop <> TWinBoolean.WinDefault then
      Attributes['loop'] := WinBooleanToString(Loop);
    if Silent <> TWinBoolean.WinDefault then
      Attributes['silent'] := WinBooleanToString(Silent);
  end;
end;

procedure TToastContentBuilder.AddAppLogoOverride(URI: TToastValue; AdaptiveCrop: TImageCrop; AltText: string);
begin
  with FXMLBinding.Nodes.AddNode('image') do
  begin
    Attributes['src'] := URI.ToXML;
    Attributes['placement'] := 'appLogoOverride';

    case AdaptiveCrop of
      TImageCrop.None:
        Attributes['hint-crop'] := 'none';
      TImageCrop.Circle:
        Attributes['hint-crop'] := 'circle';
    end;

    Attributes['alt'] := AltText;
  end;

  HandleValues([URI]);
end;

procedure TToastContentBuilder.AddAudio(CustomSound: TSoundEventValue; Loop, Silent: TWinBoolean);
begin
  AddAudio(AudioTypeToString(CustomSound), Loop, Silent);
end;

procedure TToastContentBuilder.AddButton(Content: string; ActivationType: TActivationType; Arguments, ImageURI: string);
begin
  EnsureActions;

  with FXMLActions.Nodes.AddNode('action') do
  begin
    Attributes['content'] := Content;
    Attributes['arguments'] := Arguments;

    var S: string;
    S := '';
    case ActivationType of
      TActivationType.Foreground:
        S := 'foreground';
      TActivationType.Background:
        S := 'background';
      TActivationType.Protocol:
        S := 'protocol';
    end;
    if S <> '' then
      Attributes['activationType'] := S;

    if ImageURI <> '' then
      Attributes['imageUri'] := ImageURI;
  end;
end;

procedure TToastContentBuilder.AddComboBox(ID: string; Title: string; SelectedItemID: string; Items: TArray<TToastComboItem>);
begin
  EnsureActions;

  with FXMLActions.Nodes.AddNode('input') do
  begin
    Attributes['id'] := ID;
    Attributes['type'] := 'selection';
    Attributes['title'] := Title;
    Attributes['defaultInput'] := SelectedItemID;

    for var I := 0 to High(Items) do
      with Nodes.AddNode('selection') do
      begin
        Attributes['id'] := Items[I].ID;
        Attributes['content'] := Items[I].Content;
      end;
  end;
end;

procedure TToastContentBuilder.AddButton(Content: string; ActivationType: TActivationType; Arguments: string);
begin
  AddButton(Content, ActivationType, Arguments, '');
end;

procedure TToastContentBuilder.AddHeader(ID, Title, Arguments: string);
begin
  with FXML.Nodes.AddNode('header') do
  begin
    Attributes['id'] := ID;
    Attributes['title'] := Title;
    Attributes['arguments'] := Arguments;
  end;
end;

procedure TToastContentBuilder.AddHeroImage(URI: TToastValue; AltText: string);
begin
  with FXMLBinding.Nodes.AddNode('image') do
  begin
    Attributes['src'] := URI.ToXML;
    Attributes['placement'] := 'hero';

    Attributes['alt'] := AltText;
  end;

  HandleValues([URI]);
end;

procedure TToastContentBuilder.AddInlineImage(URI: TToastValue; AltText: string; AdaptiveCrop: TImageCrop; RemoveMargin: boolean);
begin
  with FXMLBinding.Nodes.AddNode('image') do
  begin
    Attributes['src'] := URI.ToXML;

    case AdaptiveCrop of
      TImageCrop.None:
        Attributes['hint-crop'] := 'none';
      TImageCrop.Circle:
        Attributes['hint-crop'] := 'circle';
    end;

    Attributes['alt'] := AltText;
  end;

  HandleValues([URI]);
end;

procedure TToastContentBuilder.AddInputTextBox(ID, Placeholder, Title: string);
begin
  EnsureActions;

  with FXMLActions.Nodes.AddNode('input') do
  begin
    Attributes['id'] := ID;
    Attributes['type'] := 'text';
    Attributes['title'] := Title;
    Attributes['placeHolderContent'] := Placeholder;
  end;
end;

procedure TToastContentBuilder.AddProgressBar(Title, Value: TToastValue; Indeterminate: TWinBoolean; ValueStringOverride, Status: TToastValue);
begin
  with FXMLBinding.Nodes.AddNode('progress') do
  begin
    case Indeterminate of
      TWinBoolean.WinTrue:
        Attributes['value'] := 'indeterminate';
    else
      Attributes['value'] := Value.ToXML;
    end;

    Attributes['title'] := Title.ToXML;
    const S = ValueStringOverride.ToXML;
    if S <> '' then
      Attributes['valueStringOverride'] := ValueStringOverride.ToXML;
    Attributes['status'] := Status.ToXML;
  end;

  HandleValues([Title, Value, ValueStringOverride, Status]);
end;

procedure TToastContentBuilder.AddProgressBar(Title, Value: TToastValue);
begin
  AddProgressBar(Title, Value, TWinBoolean.WinFalse, TToastValueString.Create(''),
    TToastValueString.Create(''));
end;

procedure TToastContentBuilder.AddText(AText: TToastValue);
begin
  FXMLBinding.Nodes.AddNode('text').Contents := AText.ToXML;

  HandleValues([AText]);
end;

constructor TToastContentBuilder.Create;
begin
  FXML := TWinXMLDocument.Create;
  FXML.TagName := 'toast';

  FXMLVisual := FXML.Nodes.AddNode('visual');
  FXMLBinding := FXMLVisual.Nodes.AddNode('binding');
  FXMLBinding.Attributes['template'] := 'ToastGeneric';
end;

destructor TToastContentBuilder.Destroy;
begin
  FXML.Free;
  inherited;
end;

procedure TToastContentBuilder.EnsureActions;
begin
  if FXMLActions = nil then
    FXMLActions := FXML.Nodes.AddNode('actions');
end;

function TToastContentBuilder.GetXML: TDomXMLDocument;
begin
  Result := TDomXMLDocument.Create;
  const XML = FXML.OuterXML;

  Result.Parse(XML);
end;

procedure TToastContentBuilder.HandleValues(AValues: TArray<TToastValue>);
begin
  for var I := 0 to High(AValues) do
  begin
    // Free memory
    AValues[I].Free;
  end;
end;

procedure TToastContentBuilder.SetBackgroundActivation;
begin
  FXML.Attributes['activationType'] := 'background';
end;

procedure TToastContentBuilder.SetProtocolActivation(URI: string);
begin
  FXML.Attributes['activationType'] := 'protocol';
  FXML.Attributes['launch'] := URI;
end;

procedure TToastContentBuilder.SetToastDuration(Duration: TToastDuration);
const
  ATTR = 'duration';
begin
  case Duration of
    TToastDuration.Default:
      FXML.Attributes.DeleteAttribute(ATTR);
    TToastDuration.Short:
      FXML.Attributes[ATTR] := 'Short';
    TToastDuration.Long:
      FXML.Attributes[ATTR] := 'Long';
  end;
end;

procedure TToastContentBuilder.SetToastScenario(Scenario: TToastScenario);
const
  ATTR = 'scenario';
begin
  case Scenario of
    TToastScenario.Default:
      FXML.Attributes.DeleteAttribute(ATTR);
    TToastScenario.Alarm:
      FXML.Attributes[ATTR] := 'Alarm';
    TToastScenario.Reminder:
      FXML.Attributes[ATTR] := 'Reminder';
    TToastScenario.IncomingCall:
      FXML.Attributes[ATTR] := 'IncomingCall';
  end;
end;

{ TNotification }

function TNotification.Content: TXMLInterface;
begin
  Result := FToast.Content;
end;

constructor TNotification.Create(XMLDocument: TDomXMLDocument);
begin
  Initiate(XMLDocument.DomXML);
end;

destructor TNotification.Destroy;
begin
  FreeEvents;
  FToast := nil;
  FToast2 := nil;
  FToast3 := nil;
  FToast4 := nil;
  FToast6 := nil;
  FData.Free;

  inherited;
end;

procedure TNotification.FreeEvents;
begin
  if FHandleActivated <> nil then
  begin
    FHandleActivated.Unscribe;
    FHandleActivated := nil;
  end;
  if FHandleDismissed <> nil then
  begin
    FHandleDismissed.Unscribe;
    FHandleDismissed := nil;
  end;
  if FHandleFailed <> nil then
  begin
    FHandleFailed.Unscribe;
    FHandleFailed := nil;
  end;
end;

function TNotification.GetExireReboot: boolean;
begin
  Result := FToast6.ExpiresOnReboot;
end;

function TNotification.GetExpiration: TDateTime;
begin
  Result := DateTimeToTDateTime(FToast.ExpirationTime.Value);
end;

function TNotification.GetGroup: string;
begin
  const HStr = FToast2.Group;
  Result := HStr.ToString;
  HStr.Free;
end;

function TNotification.GetMirroring: NotificationMirroring;
begin
  Result := FToast3.NotificationMirroring_;
end;

function TNotification.GetPriority: ToastNotificationPriority;
begin
  Result := FToast4.Priority;
end;

function TNotification.GetRemoteID: string;
begin
  const HStr = FToast3.RemoteId;
  Result := HStr.ToString;
  HStr.Free;
end;

function TNotification.GetSuppress: boolean;
begin
  Result := FToast2.SuppressPopup;
end;

function TNotification.GetTag: string;
begin
  const HStr = FToast2.Tag;
  Result := HStr.ToString;
  HStr.Free;
end;

procedure TNotification.Initiate(XML: Xml_Dom_IXmlDocument);
begin
  FToast := TToastNotification.CreateToastNotification(XML);

  if Supports(FToast, IID_IToastNotification2) then
    FToast.QueryInterface(IID_IToastNotification2, FToast2);
  if Supports(FToast, IID_IToastNotification3) then
    FToast.QueryInterface(IID_IToastNotification3, FToast3);
  if Supports(FToast, IID_IToastNotification4) then
    FToast.QueryInterface(IID_IToastNotification4, FToast4);
  if Supports(FToast, IID_IToastNotification6) then
    FToast.QueryInterface(IID_IToastNotification6, FToast6);

  if Supports(FToast, IID_IScheduledToastNotifier) then
    FToast.QueryInterface(IID_IScheduledToastNotifier, FToastScheduled);
end;

procedure TNotification.Reset;
begin
  const PrevToast = FToast;
  const PrevToast2 = FToast2;
  const PrevToast3 = FToast2;
  const PrevToast4 = FToast2;
  const PrevToast6 = FToast2;

  // Events
  FreeEvents;

  // Clear
  FPosted := false;

  FToast := nil;
  FToast2 := nil;
  FToast3 := nil;
  FToast4 := nil;
  FToast6 := nil;

  // Create
  Initiate(prevToast.Content);

  FToast.ExpirationTime := prevToast.ExpirationTime;
  if not PrevToast2.Tag.Empty then
    FToast2.Tag := PrevToast2.Tag;
  if not PrevToast2.Group.Empty then
    FToast2.Group := PrevToast2.Group;
  FToast2.SuppressPopup := PrevToast2.SuppressPopup;
  FToast3.NotificationMirroring_ := FToast3.NotificationMirroring_;
  if not FToast3.RemoteId.Empty then
    FToast3.RemoteId := FToast3.RemoteId;
  FToast4.Priority := FToast4.Priority;
  FToast6.ExpiresOnReboot := FToast6.ExpiresOnReboot;

  // Reset data
  FToast4.Data := FData.Data;
end;

procedure TNotification.SetData(const Value: TNotificationData);
begin
  FData := Value;
  FToast4.Data := Value.Data;
end;

procedure TNotification.SetEventActivated(const Value: TOnToastActivated);
begin
  FOnActivated := Value;

  if @FOnActivated = nil then
    FHandleActivated := nil
  else
    FHandleActivated := TNotificationActivatedHandler.Create(Self);
end;

procedure TNotification.SetEventDismissed(const Value: TOnToastDismissed);
begin
  FOnDismissed := Value;

  if @FOnDismissed = nil then
    FHandleDismissed := nil
  else
    FHandleDismissed := TNotificationDismissedHandler.Create(Self);
end;

procedure TNotification.SetEventFailed(const Value: TOnToastFailed);
begin
  FOnFailed := Value;
  if @FOnFailed = nil then
    FHandleFailed := nil
  else
    FHandleFailed := TNotificationFailedHandler.Create(Self);
end;

procedure TNotification.SetExpiration(const Value: TDateTime);
var
  Reference: IReference_1__DateTime;
begin
  // Create a new instance of IReference_1__DateTime
  TPropertyValue.CreateDateTime(
    TDateTimeToDateTime(Value)
    ).QueryInterface(IReference_1__DateTime, Reference);

  // Now you can assign this reference to ExpirationTime
  FToast.ExpirationTime := Reference;
end;

procedure TNotification.SetExpireReboot(const Value: boolean);
begin
  FToast6.ExpiresOnReboot := Value;
end;

procedure TNotification.SetGroup(const Value: string);
begin
  const HStr = HString.Create(Value);
  FToast2.Group;
  HStr.Free;
end;

procedure TNotification.SetMirroring(const Value: NotificationMirroring);
begin
  FToast3.NotificationMirroring_ := Value;
end;

procedure TNotification.SetPriority(const Value: ToastNotificationPriority);
begin
  FToast4.Priority := Value;
  ;
end;

procedure TNotification.SetRemoteID(const Value: string);
begin
  const HStr = HString.Create(Value);
  FToast3.RemoteId := HStr;
  HStr.Free;
end;

procedure TNotification.SetSuppress(const Value: boolean);
begin
  FToast2.SuppressPopup := Value;
end;

procedure TNotification.SetTag(const Value: string);
begin
  const HStr = HString.Create(Value);
  FToast2.Tag := HStr;
  HStr.Free;
end;

{ TNotificationData }

procedure TNotificationData.Clear;
begin
  Data.Values.Clear;
end;

constructor TNotificationData.Create;
var
  Instance: IInspectable;
begin
  // Runtime class
  Instance := FactoryCreateInstance('Windows.UI.Notifications.NotificationData');

  // Query the interface
  Instance.QueryInterface(INotificationData, Data);
end;

destructor TNotificationData.Destroy;
begin
  Data := nil;
  inherited;
end;

function TNotificationData.GetSeq: cardinal;
begin
  Result := Data.SequenceNumber;
end;

function TNotificationData.GetValue(Key: string): string;
begin
  const HKey = HString.Create(Key);
  try
    if Data.Values.HasKey(HKey) then
    begin
      const HData = Data.Values.Lookup(HKey);
      try
        Result := HData.ToString;
      finally
        HData.Free;
      end;
    end;
  finally
    HKey.Free;
  end;
end;

procedure TNotificationData.IncreaseSequence;
begin
  SequenceNumber := SequenceNumber + 1;
end;

procedure TNotificationData.SetSeq(const Value: cardinal);
begin
  Data.SequenceNumber := Value;
end;

procedure TNotificationData.SetValue(Key: string; const Value: string);
begin
  const HKey = HString.Create(Key);
  const HData = HString.Create(Value);
  try
    if Data.Values.HasKey(HKey) then
      Data.Values.Remove(HKey);

    Data.Values.Insert(HKey, HData);
  finally
    HKey.Free;
    HData.Free;
  end;
end;

function TNotificationData.ValueCount: cardinal;
begin
  Result := Data.Values.Size;
end;

function TNotificationData.ValueExists(Key: string): boolean;
begin
  const HStr = HString.Create(Key);
  try
    Result := Data.Values.HasKey(HStr);
  finally
    HStr.Free;
  end;
end;

{ TToastValueSingle }

constructor TToastValueSingle.Create(AValue: single);
begin
  Value := AValue;
end;

function TToastValueSingle.ToXML: string;
begin
  Result := Value.ToString;
end;

{ TNotificationEventHandler }

constructor TNotificationEventHandler.Create(const ANotification: TNotification);
begin
  FNotification := ANotification;
  FToken.Value := -1;
end;

destructor TNotificationEventHandler.Destroy;
begin
  FNotification := nil;
  inherited;
end;

{ TUserInputMap }

constructor TUserInputMap.Create(LookupMap: IMap_2__HSTRING__IInspectable);
begin
  FMap := LookupMap;
end;

destructor TUserInputMap.Destroy;
begin
  FMap := nil;
end;

function TUserInputMap.GetIntValue(ID: string): integer;
begin
  const HStr = HString.Create(ID);
  if not FMap.HasKey(HStr) then
    Exit(0);
  try
    Result := (FMap.Lookup(HStr) as IPropertyValue).GetInt32;
  finally
    HStr.Free;
  end;
end;

function TUserInputMap.GetStringValue(ID: string): string;
begin
  const HStr = HString.Create(ID);
  try
    if not FMap.HasKey(HStr) then
      Exit('');
    const HRes = (FMap.Lookup(HStr) as IPropertyValue).GetString;
    try
      Result := HRes.ToString;
    finally
      HRes.Free;
    end;
  finally
    HStr.Free;
  end;
end;

function TUserInputMap.HasValue(ID: string): boolean;
begin
  const HStr = HString.Create(ID);
  try
    Result := FMap.HasKey(HStr);
  finally
    HStr.Free;
  end;
end;

end.

