# Cod-Notification-Manager
Notification Manager for advanced notifications in Windows 10/11

## Example demo
![anim](https://github.com/Codrax/Cod-Notification-Manager/assets/68193064/33026b0f-b11a-4c27-993e-69f6850db506)


## Examples
### Create notification manager
```
  Manager := TNotificationManager.Create('App.Test');

  Manager.ApplicationName := 'Amazing application';
  Manager.ShowInSettings := true;
```

### Creating a notification
```
 var NotifyContent := TToastContentBuilder.Create;
  try
    with NotifyContent do
    begin
      AddText(TToastValueBindable.Create('title'));
      AddText(TToastValueString.Create('This is the new notifications engine :)'));

      AddAudio(TSoundEventValue.NotificationIM, TWinBoolean.WinFalse);
      AddInputTextBox('editbox-id', 'Hint', 'Edit title');

      AddAppLogoOverride(TToastValueString.Create('C:\Windows\System32\@facial-recognition-windows-hello.gif'), TImageCrop.Circle);
      //AddInlineImage(TToastValueString.Create('C:\Windows\System32\@facial-recognition-windows-hello.gif'));
      //AddHeroImage(TToastValueString.Create('C:\Windows\System32\@facial-recognition-windows-hello.gif'));
      AddProgressBar(TToastValueString.Create('Downloading...'), TToastValueBindable.Create('download-pos'));

      AddButton('Cancel', TActivationType.Foreground, 'cancel');
      AddButton('View more', TActivationType.Foreground, 'view');
    end;

    var Notif: TNotification;
    // Data
    var XmlData := NotifyContent.GetXML;
    try
      Notif := TNotification.Create(XmlData);
    finally
      XmlData.Free;
    end;

    Notif.Tag := 'notification1';

    // Data binded values
    Notif.Data := TNotificationData.Create;
    Notif.Data['title'] := 'Hello world!';
    Notif.Data['download-pos'] := '0';

    // Events (must be defined in your form class)
    Notif.OnActivated := NotifActivated;
    Notif.OnDismissed := NotifDismissed;

    FNotifyManager.ShowNotification(Notif);
    Notif.Free;
  finally
    NotifyContent.Free;
  end;
```

### Pushing notification
```
  Manager.ShowNotification(Notif);
```


### Hiding notification
```
  Manager.HideNotification(Notif);
```

### Updating notification contents
```
  const DownloadValue = Notif.Data['download-pos'].ToSingle + 0.1;
  Notif.Data['download-pos'] := DownloadValue.ToString;
  if DownloadValue >= 1 then
    Notif.Data['title'] := 'Download finalised!';

  // Update
  Manager.UpdateNotification(Notif);
```

### Reading event data
```
procedure TForm1.NotifActivated(Sender: TNotification; Arguments: string; UserInput: TUserInputMap);
begin
  if Arguments = 'view' then
    begin
      // Get value of edit box (if there is one with this id)
      var Value := UserInput.GetStringValue('editbox-id');
      ShowUIMessage(Self, Value);
    end;
end;
```

## Important notes
- Do not free the `TNotificationManager` until the app will no longer send notification.
- Do not free the notification until It is no longer needed, because you will no longer be able to hide It. The notification can be reset using the `Reset()`
 method
