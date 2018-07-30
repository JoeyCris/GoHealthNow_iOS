//
//  NotificationDuplicateCheckClass.h

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface NotificationDuplicateCheckClass : NSObject {
    BOOL isDuplicate;
}

@property UIAlertController *alert;

+(NotificationDuplicateCheckClass *)getInstance;

@property (nonatomic) BOOL isDuplicate;

-(BOOL)isDuplicateNotificationTimeUsingNotificationTimeString:(NSString *)timeString;
-(void)showDuplicateAlert;

@end
