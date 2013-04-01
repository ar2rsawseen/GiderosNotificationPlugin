<h2>IOS</h2>
<h4>1) Gideros project</h4>
<ul>
<li>Create Gideros project</li>
<li>Export it as Android project</li>
<li>Import it in Eclipse</li>
</ul>
<h4>2) Copying files</h4>
<ul>
<li>Copy Plugins/Notification folder int your Xcode project's Plugins folder</li>
<li>Add files to your Xcode project:
<ul>
<li>Right click on Plugins folder in your Xcode project</li>
<li>Select Add file to "Your project name"</li>
<li>Select: Create groups for any added folders</li>
<li>select Notification folder and click Add</li>
</ul>
</li>
</ul>
<h4>3) Modify AppDelegate file</h4>
<ul>
<li>Add these methods at the end of AppDelegate.m file class:</li>
<ul>
<li><pre>- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    NSDictionary *dic = [NSDictionary dictionaryWithObject:notification forKey:@"notification"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"onLocalNotification" object:self userInfo:dic];
}</pre></li>
<li><pre>- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"onPushNotification" object:self userInfo:userInfo];
}</pre></li>
<li><pre>- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    NSDictionary *dic = [NSDictionary dictionaryWithObject:[deviceToken description] forKey:@"token"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"onPushRegistration" object:self userInfo:dic];
}</pre></li>
<li><pre>- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    NSDictionary *dic = [NSDictionary dictionaryWithObject:error forKey:@"error"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"onPushRegistrationError" object:self userInfo:dic];
}</pre></li>
</ul>
</ul>