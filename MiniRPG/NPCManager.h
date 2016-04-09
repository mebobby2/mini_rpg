//
//  NPCManager.h
//  MiniRPG
//
//  Created by Bobby Lei on 9/04/16.
//
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class GameLayer;

@interface NPCManager : NSObject
@property(nonatomic, strong) NSMutableDictionary *npcs;

-(id)initWithGameLayer:(GameLayer*)layer;
-(void)interactWithNPCNamed:(NSString*)npcName;
-(void)loadNPCsForTileMap:(CCTMXTiledMap*)map named:(NSString*)name;
@end
