//
//  NPCManager.m
//  MiniRPG
//
//  Created by Bobby Lei on 9/04/16.
//
//

#import "NPCManager.h"
#import "LuaObjCBridge.h"
#import "GameLayer.h"
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>


@interface NPCManager()
@property(nonatomic) lua_State *luaState;
@property(nonatomic, strong) GameLayer* gameLayer;
@end

@implementation NPCManager

-(id)initWithGameLayer:(GameLayer *)layer {
    if (self = [super init]) {
        self.npcs = [@{} mutableCopy];
        self.gameLayer = layer;
        
        self.luaState = lua_objc_init();
        
        lua_pushstring(self.luaState, "game");
        lua_objc_pushid(self.luaState, self.gameLayer);
        lua_settable(self.luaState, LUA_GLOBALSINDEX);
    }
    return self;
}

-(void)loadNPCsForTileMap:(CCTMXTiledMap *)map named:(NSString *)name {
    [self runLua:@"npcs = {}"];
    [self loadLuaFilesForMap:map layerName:@"npc" named:name];
}

-(void)interactWithNPCNamed:(NSString *)npcName {
    NSString* luaCode = [NSString stringWithFormat:@"npcs[\"%@\"]:interact()", npcName];
    [self runLua:luaCode];
}

- (void) loadLuaFilesForMap:(CCTMXTiledMap *) map layerName:(NSString *) layerName named:(NSString *) name
{
    NSFileManager *manager = [NSFileManager defaultManager];
    CCTMXLayer *layer = [map layerNamed:layerName];
    
    // Enumerate the layer
    for(int i = 0; i < layer.layerSize.width; i++)
    {
        for(int j = 0; j < layer.layerSize.height; j++)
        {
            CGPoint tileCoord = CGPointMake(j,i);
            int tileGid = [layer tileGIDAt:tileCoord];
            
            // Check to see if there is an NPC at this location
            if(tileGid)
            {
                // Fetch the name of the NPC
                NSDictionary *properties = [map propertiesForGID:tileGid];
                NSString *npcName = [properties objectForKey:@"name"];
                
                // Resolve the path to the NPCs Lua file
                NSString *roomName = [name stringByReplacingOccurrencesOfString:@".tmx" withString:@""];
                NSString *npcFilename = [NSString stringWithFormat:@"%@-%@.lua",roomName,npcName];
                NSString *path = [[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"npc"] stringByAppendingPathComponent:npcFilename];
                
                // If the NPC has a Lua file, initialize it.
                if([manager fileExistsAtPath:path])
                {
                    NSError *error = nil;
                    NSString *lua = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
                    if(!error)
                    {
                        [self runLua:lua];
                    }
                    else
                    {
                        NSLog(@"Error loading NPC: %@",error);
                    }
                }
                else
                {
                    NSLog(@"Warning: No Lua file for npc %@ at path %@",npcName,path);
                }
            }
        }
    }
    
}

- (void) runLua:(NSString *) luaCode
{
    char buffer[256] = {0};
    int out_pipe[2];
    int saved_stdout;
    
    // Set up pipes for output
    saved_stdout = dup(STDOUT_FILENO);
    pipe(out_pipe);
    fcntl(out_pipe[0], F_SETFL, O_NONBLOCK);
    dup2(out_pipe[1], STDOUT_FILENO);
    close(out_pipe[1]);
    
    // Run Lua
    luaL_loadstring(self.luaState, [luaCode UTF8String]);
    int status = lua_pcall(self.luaState, 0, LUA_MULTRET, 0);
    
    // Report errors if there are any
    report_errors(self.luaState, status);
    
    // Grab the output
    read(out_pipe[0], buffer, 255);
    dup2(saved_stdout, STDOUT_FILENO);
    
    // Print the output to the log
    NSString *output = [NSString stringWithFormat:@"%@",
                        [NSString stringWithCString:buffer encoding:NSUTF8StringEncoding]];
    if(output && [output length] > 2)
    {
        NSLog(@"Lua: %@",output);
    }
}

/**
 * Reports Lua errors to the console
 */
void report_errors(lua_State *L, int status)
{
    if ( status!=0 ) {
        const char *error = lua_tostring(L, -1);
        NSLog(@"Lua Error: %s",error);
        lua_pop(L, 1); // remove error message
    }
}

@end
