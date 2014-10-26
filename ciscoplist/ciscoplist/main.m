//
//  main.m
//  ciscoplist
//
//  Created by Tiny on 14-10-26.
//  Copyright (c) 2014年 wanglei. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>

BOOL runProcessAsAdministrator(NSString *scriptPath, NSArray *arguments, NSString **output, NSString **errorDescription);

int main(int argc, const char * argv[])
{
    NSString *ciscoplist = [[NSBundle mainBundle] pathForResource:@"com.cisco.CiscoWebCommunicator" ofType:@"plist"];
    NSString *shell = [[NSBundle mainBundle] pathForResource:@"changeplist" ofType:@"sh"];
    
    NSString * output = nil;
    NSString * processErrorDescription = nil;
    runProcessAsAdministrator(shell, @[ciscoplist], &output, &processErrorDescription);
    
}



BOOL runProcessAsAdministrator(NSString *scriptPath, NSArray *arguments, NSString **output, NSString **errorDescription)
{
    
    NSString * allArgs = [arguments componentsJoinedByString:@" "];
    NSString * fullScript = [NSString stringWithFormat:@"'%@' %@", scriptPath, allArgs];
    
    NSDictionary *errorInfo = [NSDictionary new];
    NSString *script =  [NSString stringWithFormat:@"do shell script \"%@\" with administrator privileges", fullScript];
    
    NSAppleScript *appleScript = [[NSAppleScript new] initWithSource:script];
    NSAppleEventDescriptor * eventResult = [appleScript executeAndReturnError:&errorInfo];
    
    // Check errorInfo
    if (! eventResult)
    {
        // Describe common errors
        *errorDescription = nil;
        if ([errorInfo valueForKey:NSAppleScriptErrorNumber])
        {
            NSNumber * errorNumber = (NSNumber *)[errorInfo valueForKey:NSAppleScriptErrorNumber];
            if ([errorNumber intValue] == -128)
                *errorDescription = @"The administrator password is required to do this.";
        }
        
        // Set error message from provided message
        if (*errorDescription == nil)
        {
            if ([errorInfo valueForKey:NSAppleScriptErrorMessage])
                *errorDescription =  (NSString *)[errorInfo valueForKey:NSAppleScriptErrorMessage];
        }
        
        return NO;
    }
    else
    {
        // Set output to the AppleScript's output
        *output = [eventResult stringValue];
        
        return YES;
    }
}
