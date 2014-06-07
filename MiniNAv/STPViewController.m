//
//  STPViewController.m
//  LaBoite
//
//  Created by Nanook on 06/06/2014.
//  Copyright (c) 2014 SaveThePlan. All rights reserved.
//

#import "STPViewController.h"
#import "STPLayoutConstraintBuilder.h"

@interface STPViewController () {
    BOOL isIOS6, isIpad;
    
    UIWebView * webView;
    UIToolbar * toolbar;
    UIBarButtonItem * homeTbBt, * backTbBt, * fwdTbBt, * urlTbBt, * bookmarkTbBt, * addTbBt;
    
    NSString * homeStringUrl;
    
    NSMutableDictionary * bookmarks;
    
    UIAlertView * urlTypeAlert, * addBookmarkAlert;

    UIActionSheet * addActionSheet, * bookmarkActionSheet;
    
}

@end

@implementation STPViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    isIOS6 = ([[[UIDevice currentDevice] systemVersion] characterAtIndex:0] == '6');
    isIpad = ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad);
    
    homeStringUrl = @"http://google.fr";
    
    bookmarks = [[NSMutableDictionary alloc]init];
    [bookmarks setObject:@"https://www.france-universite-numerique-mooc.fr/"
                  forKey:@"FUN"];
    [bookmarks setObject:@"http://www.apple.com/" forKey:@"Apple"];
    
    [self loadBackground];
    [self constructInterface];
    
    [self willRotateToInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]
                                  duration:[[UIApplication sharedApplication] statusBarOrientationAnimationDuration]];
    
}

-(void)loadBackground {
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    
    UIImage * background;
    
    if(screenSize.width > 568 || screenSize.height > 568) {
        background = [UIImage imageNamed:@"fond-2048x2048.jpg"];
    } else if(screenSize.width > 480 || screenSize.height > 480) {
        background = [UIImage imageNamed:@"fond-1136x1136.jpg"];
    } else {
        background = [UIImage imageNamed:@"fond-1024x1024.jpg"];
    }
    
    [[self view] setBackgroundColor:[UIColor colorWithPatternImage:background]];
    
}

-(void)constructInterface {
    
    //webView
    webView = [[UIWebView alloc] init];
    [webView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [webView setDelegate:self];
    [[self view] addSubview:webView];
    [webView release];
    
    //toolbar
    toolbar = [[UIToolbar alloc]init];
    [toolbar setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    if(isIOS6){
        [toolbar setBarStyle:UIBarStyleBlackTranslucent];
    } else {
        [toolbar setBarStyle:UIBarStyleDefault];
    }
    [[self view] addSubview:toolbar];
    [toolbar release];
    
    //toolbar spaces
    UIBarButtonItem * fixSpace = [[UIBarButtonItem alloc]
                                  initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                  target:nil action:@selector(alloc)];
    UIBarButtonItem * flexSpace = [[UIBarButtonItem alloc]
                                   initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                   target:nil action:@selector(alloc)];
    
    //toolbar buttons
    homeTbBt = [[UIBarButtonItem alloc]
                initWithBarButtonSystemItem:UIBarButtonSystemItemReply
                target:self action:@selector(onHomeTbBtClick)];
    urlTbBt = [[UIBarButtonItem alloc]
               initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
               target:self action:@selector(onUrlTbBtClick)];
    backTbBt = [[UIBarButtonItem alloc]
                initWithBarButtonSystemItem:UIBarButtonSystemItemRewind
                target:self action:@selector(onNavigationTbBtClick:)];
    [backTbBt setEnabled:NO];
    fwdTbBt = [[UIBarButtonItem alloc]
               initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward
               target:self action:@selector(onNavigationTbBtClick:)];
    [fwdTbBt setEnabled:NO];
    bookmarkTbBt = [[UIBarButtonItem alloc]
                    initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks
                    target:self action:@selector(onBookmarkTbBtClick)];
    addTbBt = [[UIBarButtonItem alloc]
               initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
               target:self action:@selector(onAddTbBtClick)];
    
    //buttons to toolbar
    [toolbar setItems:[NSArray arrayWithObjects:homeTbBt, flexSpace,
                       backTbBt, fixSpace, urlTbBt, fixSpace, fwdTbBt, flexSpace,
                       addTbBt, fixSpace, bookmarkTbBt,
                       nil]];
    
    [homeTbBt release];
    [backTbBt release];
    [fwdTbBt release];
    [urlTbBt release];
    [bookmarkTbBt release];
    [addTbBt release];

    
    
    
    //CONSTRAINTS
    NSDictionary * viewDictionary = NSDictionaryOfVariableBindings(webView, toolbar);
    [[self view] addConstraints:[NSLayoutConstraint
                                 constraintsWithVisualFormat:@"H:|[toolbar]|"
                                 options:NSLayoutFormatDirectionLeftToRight
                                 metrics:nil views:viewDictionary]];
    [[self view] addConstraints:[NSLayoutConstraint
                                 constraintsWithVisualFormat:@"H:|-[webView]-|"
                                 options:NSLayoutFormatDirectionLeftToRight
                                 metrics:nil views:viewDictionary]];
    [[self view] addConstraints:[NSLayoutConstraint
                           constraintsWithVisualFormat:@"V:|-0-[toolbar]-[webView]-|"
                           options:NSLayoutFormatDirectionLeftToRight
                           metrics:nil views:viewDictionary]];
    
    //url alert
    urlTypeAlert = [[UIAlertView alloc]
                initWithTitle:@"Charger une page"
                message:@"Saisir une url"
                delegate:self
                cancelButtonTitle:@"Annuler"
                otherButtonTitles:@"OK", nil];
    [urlTypeAlert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    
    //add bookmark alert
    addBookmarkAlert = [[UIAlertView alloc]
                        initWithTitle:@"ajouter aux favoris"
                        message:@""
                        delegate:self
                        cancelButtonTitle:@"annuler"
                        otherButtonTitles:@"OK", nil];
    [addBookmarkAlert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    
    //add action sheet
    addActionSheet = [[UIActionSheet alloc]
                      initWithTitle:@"Conserver cette page"
                      delegate:self
                      cancelButtonTitle:@"Annuler"
                      destructiveButtonTitle:@"Comme page d'accueil"
                      otherButtonTitles:@"Comme favori", nil];
    
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)shouldAutorotate {
    return YES;
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    BOOL isLandscape = (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft
                   || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight);
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    
    if(isLandscape){
        [[self view] setFrame:CGRectMake(0, 0, screenBounds.size.height, screenBounds.size.width)];
    } else {
        [[self view] setFrame:CGRectMake(0, 0, screenBounds.size.width, screenBounds.size.height)];
    }
    
}


/* ---- web view delegate ---- */

-(void)webViewDidFinishLoad:(UIWebView *)wView {
    [backTbBt setEnabled:[webView canGoBack]];
    [fwdTbBt setEnabled:[webView canGoForward]];
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    UIAlertView * errorAlert = [[UIAlertView alloc]
                                initWithTitle:@"erreur"
                                message:[NSString stringWithFormat:@"%@", [error localizedDescription]]
                                delegate:nil
                                cancelButtonTitle:@"OK"
                                otherButtonTitles:nil];
    [errorAlert autorelease];
    [errorAlert show];
}

/* ---- END web view delegate ---- */


/* ---- toolbar buttons actions ---- */

-(void)onHomeTbBtClick {
    NSURL * url = [NSURL URLWithString:homeStringUrl];
    NSURLRequest * rq = [NSURLRequest requestWithURL:url];
    [webView loadRequest:rq];
}

-(void)onNavigationTbBtClick:(id)sender {
    if(sender == backTbBt) {
        [webView goBack];
    } else {
        [webView goForward];
    }
    [[self view] setNeedsDisplay];
}

-(void)onUrlTbBtClick {
    [urlTypeAlert show];
}

-(void)onBookmarkTbBtClick {
    if(bookmarkActionSheet != nil) {
        [bookmarkActionSheet release];
    }
    
    //bookmark action sheet
    bookmarkActionSheet = [[UIActionSheet alloc]
                           initWithTitle:@"Favoris"
                           delegate:self
                           cancelButtonTitle:@"Annuler"
                           destructiveButtonTitle:@"Page d'accueil"
                           otherButtonTitles:nil];
    
}

-(void)onAddTbBtClick {
    if(isIpad) {
        [addActionSheet showFromBarButtonItem:addTbBt animated:YES];
    } else {
        [addActionSheet showFromToolbar:toolbar];
    }
}

/* ---- END toolbar buttons actions ---- */


/* ---- alert view delegate ---- */

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if(alertView == urlTypeAlert){
        if(buttonIndex == 1){
            NSURL * newUrl = [NSURL URLWithString:[[alertView textFieldAtIndex:0] text]];
            NSURLRequest * newRq = [NSURLRequest requestWithURL:newUrl];
            [webView loadRequest:newRq];
        }
    }
    
    if(alertView == addBookmarkAlert) {
        if(buttonIndex == 1) {
            [bookmarks setObject:[alertView message]
                          forKey:[[alertView textFieldAtIndex:0] text]];
        }
    }
}

/* ---- END alert view delegate ---- */

/* ---- actionsheet delegate ---- */

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(actionSheet == addActionSheet) {
        if(buttonIndex == 0){
            //modify home page
            homeStringUrl = [[[webView request] URL] absoluteString];
        }
        if(buttonIndex == 1){
            //add to bookmarks
            [addBookmarkAlert setMessage:[[[webView request] URL] absoluteString]];
            [addBookmarkAlert show];
        }
    }

}

/* ---- END actionsheet delegate ---- */



-(void)dealloc {
    [webView release]; webView = nil;
    [toolbar release]; toolbar = nil;
    [homeTbBt release]; homeTbBt = nil;
    [backTbBt release]; backTbBt = nil;
    [fwdTbBt release]; fwdTbBt = nil;
    [urlTbBt release]; urlTbBt = nil;
    [bookmarkTbBt release]; bookmarkTbBt = nil;
    [addTbBt release]; addTbBt = nil;
    
    [homeStringUrl release]; homeStringUrl = nil;
    [bookmarks release]; bookmarks = nil;

    [urlTypeAlert release]; urlTypeAlert = nil;
    [addBookmarkAlert release]; addBookmarkAlert = nil;
    
    [bookmarkActionSheet release]; bookmarkActionSheet = nil;
    [addActionSheet release]; addActionSheet = nil;
    
    [super dealloc];
}

@end
