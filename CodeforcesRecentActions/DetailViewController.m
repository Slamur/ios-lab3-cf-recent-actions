//
//  DetailViewController.m
//  CodeforcesRecentActions
//
//  Created by Admin on 28.05.16.
//  Copyright © 2016 SSAU. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()

@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem {
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
            
        // Update the view.
        [self configureView];
    }
}

- (void)configureView {
    // Update the user interface for the detail item.
    if (self.detailItem) {
        
        NSDictionary *recentAction = (NSDictionary*)self.detailItem;
        
        NSInteger maxTextLength = 10020;
        
        NSDictionary *blog = recentAction[@"blogEntry"];
        
        NSString *authorHandle = blog[@"authorHandle"];
        NSString *title = blog[@"title"];
        
        NSDictionary *commentAction = recentAction[@"comment"];
        if (commentAction != nil) {
            // new comment
            NSString *commentatorHandle = commentAction[@"commentatorHandle"];
            NSString *text = commentAction[@"text"];
            if ([text length] > maxTextLength) {
                text = [NSString stringWithFormat:@"%@...", [text substringToIndex:maxTextLength]];
            }
            
            self.detailDescriptionLabel.text = [NSString stringWithFormat:@"%@ commented blog '%@', created by %@, with comment: %@", commentatorHandle, title, authorHandle, text];
        } else {
            self.detailDescriptionLabel.text = [NSString stringWithFormat:@"%@ created blog '%@'", authorHandle, title];
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
