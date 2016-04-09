//
//  ChatBox.h
//  MiniRPG
//
//  Created by Bobby Lei on 9/04/16.
//
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface ChatBox : CCNode

-(id)initWithNPC:(NSString*)npc text:(NSString*)text;
-(void)advanceTextOrHide;

@end
