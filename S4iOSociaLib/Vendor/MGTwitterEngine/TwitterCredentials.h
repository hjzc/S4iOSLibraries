//
//  TwitterCredentials.h
//  MGTwitterEngine
//
//  Created by Darryl H. Thomas on 1/10/11.
//

#import <Foundation/Foundation.h>

// Put your twitter credentials in this file for use by the demo
// AppController.

// To ensure changes to this file will not be committed, be sure to run:
// git update-index --assume-unchanged TwitterCredentials.h

// Hard-coding credentials elsewhere in the project is inadvisable, as you
// may inadvertantly disclose this information with a careless commit.

// In production/distributed code, be sure to take additional measures to
// protect your consumer secret, never *ever* store Twitter passwords,
// and be sure to read Twitter's security best practices:
// http://dev.twitter.com/pages/security_best_practices

#define TWITTER_USERNAME @""
#define TWITTER_PASSWORD @""

#define TWITTER_CONSUMER_KEY @""
#define TWITTER_CONSUMER_SECRET @""

// If you have not received xAuth privileges for your app, you can
// test with your personal access token.

// To obtain this token, select your app from the "Your apps" list
// (http://dev.twitter.com/apps) by selecting the app and then clicking
// on the "My Access Token" link.
// If you want to use xAuth, you must leave these defined as empty
// strings.
#define TWITTER_OAUTH_TOKEN @""
#define TWITTER_OAUTH_TOKEN_SECRET @""
