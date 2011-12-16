//
//  AnnotationView.h
//  MapHub
//
//  Created by Ruokun Ren on 11/12/11.
//  Copyright (c) 2011 Cornell University. All rights reserved.
//

#import <UIKit/UIKit.h>

enum {
    NotDrawing = 0,
    BezierStateNone,
    BezierStateDefiningLine,
    BezierStateDefiningCP1,
    BezierStateDefiningCP2
};

enum{
    ANNOTATION = 0,
    BODY,
    TITLE,
    DATA
};

@interface AnnotationView : UIView <NSXMLParserDelegate>
{
    NSMutableArray *pathAnnotations;
    NSMutableArray *polygonAnnotations;
    NSMutableArray *pointAnnotations;
    NSMutableArray *pathText;
    NSMutableArray *polygonText;
    NSMutableArray *pointText;
    NSMutableArray *polygonTitle;
    UInt8 state;
    UInt8 parsingState;
    UIBezierPath *currentPath;
    UIView *parenetView;
    UIView *annotationInfo;
    UILabel *titleView;
    UILabel *bodyView;
    UIView *newAnnotationWindow;
    UITextField *newTitle;
    UITextView *newBody;
    UIButton *addAnnotation;
    UIButton *cancelAnnotation;
    @private
    UITouch *currentTouch;
    CGFloat scaling;
}

@property (nonatomic, retain) UIBezierPath *currentPath;
@property (nonatomic, retain) UIView *parentView;
@property UInt8 state;
@property CGFloat scaling;

- (void) loadAnnotations:(NSString*) string;
- (BOOL)containsPoint:(CGPoint)point onPath:(UIBezierPath*)path inFillArea:(BOOL)inFill;

@end
