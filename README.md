# WindowsNotificationManager
Notification Manager for advanced notifications in Windows 10/11

## Example demo
![anim](https://github.com/Codrax/Cod-Notification-Manager/assets/68193064/33026b0f-b11a-4c27-993e-69f6850db506)


## Examples
### Create notification manager
```pascal
Manager := TNotificationManager.Create(Self, 'App.Test');
Manager.ApplicationName := 'Amazing application';
Manager.ShowInSettings := true;
```

### Creating a notification
```pascal
var NotifyContent := TToastContentBuilder.Create
  .UseButtonStyle(True)
  .AddText(TToastText.Create.Text('{title}'))
  .AddText(TToastText.Create.Text('This is the Windows 10+ notifications engine for Delphi'))
  .AddGroup(TToastGroup.Create.SubGroups([
    TToastSubGroup.Create.HintWeight(1)
      .AddText(TToastText.Create.Text('Mon').HintAlign(TToastAdaptiveTextAlign.Center))
      .AddImage(TToastImage.Create.Src(DefImg).HintRemoveMargin(True))
      .AddText(TToastText.Create.Text('63°').HintAlign(TToastAdaptiveTextAlign.Center))
      .AddText(TToastText.Create.Text('42°').HintAlign(TToastAdaptiveTextAlign.Center).HintStyle(TToastAdaptiveTextStyle.CaptionSubtle)),
    TToastSubGroup.Create.HintWeight(1)
      .AddText(TToastText.Create.Text('Tue').HintAlign(TToastAdaptiveTextAlign.Center))
      .AddImage(TToastImage.Create.Src(DefImg).HintRemoveMargin(True))
      .AddText(TToastText.Create.Text('57°').HintAlign(TToastAdaptiveTextAlign.Center))
      .AddText(TToastText.Create.Text('38°').HintAlign(TToastAdaptiveTextAlign.Center).HintStyle(TToastAdaptiveTextStyle.CaptionSubtle)),
    TToastSubGroup.Create.HintWeight(1)
      .AddText(TToastText.Create.Text('Wed').HintAlign(TToastAdaptiveTextAlign.Center))
      .AddImage(TToastImage.Create.Src(DefImg).HintRemoveMargin(True))
      .AddText(TToastText.Create.Text('59°').HintAlign(TToastAdaptiveTextAlign.Center))
      .AddText(TToastText.Create.Text('43°').HintAlign(TToastAdaptiveTextAlign.Center).HintStyle(TToastAdaptiveTextStyle.CaptionSubtle)),
    TToastSubGroup.Create.HintWeight(1)
      .AddText(TToastText.Create.Text('Thu').HintAlign(TToastAdaptiveTextAlign.Center))
      .AddImage(TToastImage.Create.Src(DefImg).HintRemoveMargin(True))
      .AddText(TToastText.Create.Text('62°').HintAlign(TToastAdaptiveTextAlign.Center))
      .AddText(TToastText.Create.Text('42°').HintAlign(TToastAdaptiveTextAlign.Center).HintStyle(TToastAdaptiveTextStyle.CaptionSubtle)),
    TToastSubGroup.Create.HintWeight(1)
      .AddText(TToastText.Create.Text('Fri').HintAlign(TToastAdaptiveTextAlign.Center))
      .AddImage(TToastImage.Create.Src(DefImg).HintRemoveMargin(True))
      .AddText(TToastText.Create.Text('71°').HintAlign(TToastAdaptiveTextAlign.Center))
      .AddText(TToastText.Create.Text('66°').HintAlign(TToastAdaptiveTextAlign.Center).HintStyle(TToastAdaptiveTextStyle.CaptionSubtle))
  ]))
  .Audio(TToastAudio.Create.Src(TSoundEventValue.NotificationSMS).Loop(False))
  .AddInputBox(TToastTextBox.Create.Id('editbox-id').Title('Title').PlaceholderContent('Enter name'))
  .AddSelectionBox(TToastSelectionBox.Create.Id('combo').Title('Choose').Items([
      TToastSelectionBoxItem.Create('id_1', 'Yes'),
      TToastSelectionBoxItem.Create('id_2', 'No')
    ]))
  .AddButton(TToastAction.Create.Content('Cancel').ActivationType(TActivationType.Foreground).Arguments('cancel').HintButtonStyle(TToastActionButtonStyle.Critical))
  .AddButton(TToastAction.Create.Content('View more').ActivationType(TActivationType.Foreground).Arguments('view').HintInputId('editbox-id'));

var Notif := TNotification.Create(Manager, NotifyContent);
Notif.Tag := 'notification1';
// Data binded values
Notif.Data['title'] := 'Hello world!';
Notif.Data['download-pos'] := '0';
// Events (must be defined in your form class)
Notif.OnActivated := NotifActivated;
Notif.OnDismissed := NotifDismissed;
```

### Pushing notification
```pascal
Manager.ShowNotification(Notif);
```


### Hiding notification
```pascal
Manager.HideNotification(Notif);
```

### Updating notification contents
```pascal
const DownloadValue = Notif.Data['download-pos'].ToSingle + 0.1;
Notif.Data['download-pos'] := DownloadValue.ToString;
if DownloadValue >= 1 then
  Notif.Data['title'] := 'Download finalised!';

// Update
Manager.UpdateNotification(Notif);
```

### Reading event data
```pascal
procedure TFormMain.NotifActivated(Sender: TNotification; Arguments: string; UserInput: TUserInputMap);
begin
  if Arguments = 'view' then
    begin
      // Get value of edit box (if there is one with this id)
      var Value := UserInput.GetStringValue('editbox-id');
      ShowUIMessage(Self, Value);
    end;
end;

procedure TFormMain.NotifDismissed(Sender: TNotification; Reason: TToastDismissReason);
begin
  ShowUIMessage(Self, 'NotifDismissed', Ord(Reason).ToString);
end;
```

## Important notes
- Do not free the `TNotificationManager` until the app will no longer send notification.
- Do not free the notification until It is no longer needed, because you will no longer be able to hide It. The notification can be reset using the `Reset()`
 method
