//
//  ApplicationDelegate.m
//  PushMeBaby
//
//  Created by Stefan Hafeneger on 07.04.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ApplicationDelegate.h"

@interface ApplicationDelegate ()
#pragma mark Properties
@property(nonatomic, retain) NSString *deviceToken, *payload;
@property(nonatomic, retain) NSURL *certificate;
#pragma mark Private
- (void)connect;
- (void)disconnect;
@end

@implementation ApplicationDelegate

#pragma mark Allocation

- (id)init {
	self = [super init];
	if(self != nil) {
		self.deviceToken = @"1ecc7705 dae93142 af3d7435 5d180fb3 f367adb4 ce0f41cb f24c9cea f5d7ade8";
                        

		self.payload = @"{\"aps\":{\"alert\":\"This is some fany message.\",\"badge\":1,\"sound\":\"屁颠屁颠.wav\"}}";
//		self.certificate = [[NSBundle mainBundle] pathForResource:@"aps_development" ofType:@"cer"];
	}
	return self;
}

- (void)dealloc {
	
	// Release objects.
	self.deviceToken = nil;
	self.payload = nil;
	self.certificate = nil;
	
	// Call super.
	[super dealloc];
	
}


#pragma mark Properties

@synthesize deviceToken = _deviceToken;
@synthesize payload = _payload;
@synthesize certificate = _certificate;

#pragma mark Inherent

- (void)comboBoxSelectionDidChange:(NSNotification *)notification
{
  if([notification object] == iAddressBox)
  {
    address = [[notification object] indexOfSelectedItem] ;
    NSLog(@"%d",address);
    [self connect];
  }
  else
  {
    cerType = [[notification object] indexOfSelectedItem] ;
    NSLog(@"%d",cerType);
    if(cerType == 1)
    {
      [iPassworeField setHidden:NO];
      [iPassworeLabel setHidden:NO];
    }
    else
    {
      [iPassworeField setHidden:YES];
      [iPassworeLabel setHidden:YES];
    }
  }
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
	[self connect];
  address = 0;
  [iAddressBox selectItemAtIndex:0];
  [iAddressBox setStringValue:@"gateway.sandbox.push.apple.com"];
  
  cerType = 0;
  [iCerType selectItemAtIndex:0];
  [iCerType setStringValue:@".cer"];
  
  [iPassworeField setHidden:YES];
  [iPassworeLabel setHidden:YES];
}

- (void)applicationWillTerminate:(NSNotification *)notification {
	[self disconnect];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)application {
	return YES;
}

#pragma mark Private

- (void)pathControl:(NSPathControl *)pathControl willDisplayOpenPanel:(NSOpenPanel *)openPanel
{
	// change the wind title and choose buttons title
	[openPanel setAllowsMultipleSelection:NO];
	[openPanel setCanChooseDirectories:NO];
	[openPanel setCanChooseFiles:YES];
	[openPanel setResolvesAliases:YES];
	[openPanel setTitle:@"Choose a Certificate"];
	[openPanel setPrompt:@"Choose"];
}


- (IBAction)changeLocationAction:(id)sender
{
 
  NSPathControl *pathCntl = (NSPathControl *)sender;

  NSPathComponentCell *component = [pathCntl clickedPathComponentCell];
  

  self.certificate = [component URL];

   [self clearLog];
  [self connect];
}

- (NSMutableString *)getLog
{
  if(!iLog)
  {
    iLog = [[NSMutableString alloc] initWithCapacity:1];
  }
  return iLog;
}

- (void)clearLog
{
  int lenght = [self getLog].length;
  if(lenght > 0)
  {
    NSRange ra;
    ra.location = 0;
    ra.length = lenght;
    [[self getLog] deleteCharactersInRange:ra];
    [iLogView.documentView setString:nil];
  }
}
- (void)appendeLog:(NSString *)aLog
{
  NSString *str = [NSString stringWithFormat:@"%@\n",aLog];
  [[self getLog] appendString:str];
  NSTextView *textView = iLogView.documentView;
  [textView setString:[self getLog]];
}
- (void)connect {
	
	if(self.certificate == nil)
  {
		return;
	}
	
	// Define result variable.
	OSStatus result;
	
	// Establish connection to server.
	PeerSpec peer;
  
//以下为开发push服务器连接地址
  if(address == 0)
    result = MakeServerConnection("gateway.sandbox.push.apple.com", 2195, &socket, &peer);
  else
    result = MakeServerConnection("gateway.push.apple.com", 2195, &socket, &peer);
  
  //以下为发布push服务器连接地址
  NSString *strLog;

  strLog = [NSString stringWithFormat:@"MakeServerConnection(): %ld",result];
  [self appendeLog:strLog];
   NSLog(@"MakeServerConnection(): %ld", result);
	
	// Create new SSL context.
	result = SSLNewContext(false, &context);
  strLog = [NSString stringWithFormat:@"SSLNewContext(): %ld",result];
  [self appendeLog:strLog];
  NSLog(@"SSLNewContext(): %ld", result);
	
	// Set callback functions for SSL context.
	result = SSLSetIOFuncs(context, SocketRead, SocketWrite);//
  strLog = [NSString stringWithFormat:@"SSLSetIOFuncs(): %ld",result];
  [self appendeLog:strLog];
  NSLog(@"SSLSetIOFuncs(): %ld", result);
	
	// Set SSL context connection.
	result = SSLSetConnection(context, socket);//
  strLog = [NSString stringWithFormat:@"SSLSetConnection(): %ld",result];
  [self appendeLog:strLog];
  
  NSLog(@"SSLSetConnection(): %ld", result);
	
	// Set server domain name.
  
  //以下是连接开发Push服务器使用的代码
   if(address == 0)
	result = SSLSetPeerDomainName(context, "gateway.sandbox.push.apple.com", 30);//
  
  //以下是连接发布Push服务器使用的代码
  else
  result = SSLSetPeerDomainName(context, "gateway.push.apple.com", 22);//
  
  strLog = [NSString stringWithFormat:@"SSLSetPeerDomainName(): %ld",result];
  [self appendeLog:strLog];
  NSLog(@"SSLSetPeerDomainName(): %ld", result);
	
	// Open keychain.
	result = SecKeychainCopyDefault(&keychain);//
  strLog = [NSString stringWithFormat:@"SecKeychainOpen(): %ld",result];
  [self appendeLog:strLog];
  NSLog(@"SecKeychainOpen(): %ld", result);
	
	// Create certificate.
  CFArrayRef certificates = nil;
   NSData *certificateData = [NSData dataWithContentsOfURL:self.certificate];
  if(cerType == 0)
  {
    CSSM_DATA data;
    data.Data = (uint8 *)[certificateData bytes];
    data.Length = [certificateData length];
    result = SecCertificateCreateFromData(&data, CSSM_CERT_X_509v3, CSSM_CERT_ENCODING_BER, &certificate);
    strLog = [NSString stringWithFormat:@"SecCertificateCreateFromData(): %ld",result];
    [self appendeLog:strLog];
    NSLog(@"SecCertificateCreateFromData(): %ld", result);
	
    // Create identity.
    result = SecIdentityCreateWithCertificate(keychain, certificate, &identity);// NSLog(@"SecIdentityCreateWithCertificate(): %d", result);
	
    // Set client certificate.
    certificates = CFArrayCreate(NULL, (const void **)&identity, 1, NULL);
  }
  else
  {

    CFDataRef inPKCS12Data = (CFDataRef)certificateData;

    NSMutableDictionary * options = [[[NSMutableDictionary alloc] init] autorelease];
    [options setObject:iPassword forKey:(id)kSecImportExportPassphrase];
  
  
    CFArrayRef certificatesArray = CFArrayCreate(NULL, 0, 0, NULL);
    OSStatus status = SecPKCS12Import(inPKCS12Data, (CFDictionaryRef)options, &certificatesArray);
     NSLog(@"read p12 status: %ld", status);
    if (status!=noErr)
    {
      NSLog(@"获取p12文件错误！");
      strLog = [NSString stringWithFormat:@"读取证书错误。"];
      [self appendeLog:strLog];
      return;
    }
    else
    {
      CFDictionaryRef identityDict = CFArrayGetValueAtIndex(certificatesArray, 0);
    
      SecIdentityRef identityApp = (SecIdentityRef)CFDictionaryGetValue(identityDict,kSecImportItemIdentity);
      certificates = CFArrayCreate(NULL, (const void **)&identityApp, 1, NULL);
    }

  }

  if(!certificates)
  {
    strLog = [NSString stringWithFormat:@"读取证书错误。"];
    [self appendeLog:strLog];
    return;
  }
	result = SSLSetCertificate(context, certificates);
  NSLog(@"SSLSetCertificate(): %ld", result);
	CFRelease(certificates);
	
	// Perform SSL handshake.
	do {
		result = SSLHandshake(context);//
    strLog = [NSString stringWithFormat:@"SSLHandshake(): %ld",result];
    [self appendeLog:strLog];
    NSLog(@"SSLHandshake(): %ld", result);
	} while(result == errSSLWouldBlock);
	
}

- (void)disconnect {
	
	if(self.certificate == nil) {
		return;
	}
	
	// Define result variable.
	OSStatus result;
	
	// Close SSL session.
	result = SSLClose(context);// NSLog(@"SSLClose(): %d", result);
	
	// Release identity.
	CFRelease(identity);
	
	// Release certificate.
	CFRelease(certificate);
	
	// Release keychain.
	CFRelease(keychain);
	
	// Close connection to server.
	close((int)socket);
	
	// Delete SSL context.
	result = SSLDisposeContext(context);// NSLog(@"SSLDisposeContext(): %d", result);
	
}

#pragma mark IBAction

- (IBAction)push:(id)sender {
	
	if(self.certificate == nil) {
		return;
	}
	
	// Validate input.
	if(self.deviceToken == nil || self.payload == nil) {
		return;
	}
	
	// Convert string into device token data.
	NSMutableData *deviceToken = [NSMutableData data];
	unsigned value;
	NSScanner *scanner = [NSScanner scannerWithString:self.deviceToken];
	while(![scanner isAtEnd]) {
		[scanner scanHexInt:&value];
		value = htonl(value);
		[deviceToken appendBytes:&value length:sizeof(value)];
	}
	
	// Create C input variables.
	char *deviceTokenBinary = (char *)[deviceToken bytes];
	char *payloadBinary = (char *)[self.payload UTF8String];
	size_t payloadLength = strlen(payloadBinary);
	
	// Define some variables.
	uint8_t command = 0;
	char message[293];
	char *pointer = message;
	uint16_t networkTokenLength = htons(32);
	uint16_t networkPayloadLength = htons(payloadLength);
	
	// Compose message.
	memcpy(pointer, &command, sizeof(uint8_t));
	pointer += sizeof(uint8_t);
	memcpy(pointer, &networkTokenLength, sizeof(uint16_t));
	pointer += sizeof(uint16_t);
	memcpy(pointer, deviceTokenBinary, 32);
	pointer += 32;
	memcpy(pointer, &networkPayloadLength, sizeof(uint16_t));
	pointer += sizeof(uint16_t);
	memcpy(pointer, payloadBinary, payloadLength);
	pointer += payloadLength;
	
	// Send message over SSL.
	size_t processed = 0;
	OSStatus result = SSLWrite(context, &message, (pointer - message), &processed);//
  NSString *strLog = [NSString stringWithFormat:@"SSLWrite(): %ld %ld",result,processed];
  [self appendeLog:strLog];
  NSLog(@"SSLWrite(): %ld %ld", result, processed);
	
}

@end
