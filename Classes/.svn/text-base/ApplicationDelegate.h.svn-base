//
//  ApplicationDelegate.h
//  PushMeBaby
//
//  Created by Stefan Hafeneger on 07.04.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "ioSock.h"

@interface ApplicationDelegate : NSObject <NSComboBoxDelegate> {
	NSString *_deviceToken, *_payload;
  NSURL *_certificate;
	otSocket socket;
	SSLContextRef context;
	SecKeychainRef keychain;
	SecCertificateRef certificate;
	SecIdentityRef identity;
  IBOutlet NSScrollView *iLogView;
  IBOutlet NSComboBox *iAddressBox;
  IBOutlet NSComboBox *iCerType;
  IBOutlet NSSecureTextField *iPassworeField;
  IBOutlet NSTextField *iPassworeLabel;
  NSMutableString *iLog;
  NSString *iPassword;
  int address;
  int cerType;
}
#pragma mark IBAction
- (IBAction)push:(id)sender;
@end
