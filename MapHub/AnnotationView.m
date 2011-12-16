//
//  AnnotationView.m
//  MapHub
//
//  Created by Ruokun Ren on 11/12/11.
//  Copyright (c) 2011 Cornell University. All rights reserved.
//

#import "AnnotationView.h"

@implementation AnnotationView

@synthesize currentPath, state, scaling, parentView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor clearColor]];
        polygonAnnotations = [[NSMutableArray alloc] init];
        pathAnnotations = [[NSMutableArray alloc] init];
        pointAnnotations = [[NSMutableArray alloc] init];
        polygonText = [[NSMutableArray alloc] init];
        pathText = [[NSMutableArray alloc] init];
        pointText = [[NSMutableArray alloc] init];
        polygonTitle = [[NSMutableArray alloc] init];
        
        annotationInfo = [[UIView alloc] initWithFrame:CGRectMake(20, 80, 200, 100)];
        [annotationInfo setBackgroundColor:[UIColor clearColor]];
        titleView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 50)];
        [titleView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:255 alpha:0.5]];
        bodyView = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, 200, 50)];
        [bodyView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:255 alpha:0.5]];
        [annotationInfo addSubview:titleView];
        [annotationInfo addSubview:bodyView];
        
        newAnnotationWindow = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 400)];
        [newAnnotationWindow setBackgroundColor:[UIColor grayColor]];
        newTitle = [[UITextField alloc] initWithFrame:CGRectMake(256, 25, 512, 40)];
        [newTitle setBackgroundColor:[UIColor whiteColor]];
        newBody = [[UITextView alloc] initWithFrame:CGRectMake(256, 100, 512, 160)];
        [newBody setBackgroundColor:[UIColor whiteColor]];
        addAnnotation = [[UIButton alloc] initWithFrame:CGRectMake(256, 300, 150, 40)];
        [addAnnotation setTitle:@"Add annotation" forState:UIControlStateNormal];
        [addAnnotation setBackgroundColor:[UIColor whiteColor]];
        [addAnnotation setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [addAnnotation addTarget:self action:@selector(addAnnotation:) forControlEvents:UIControlEventTouchDown];
        cancelAnnotation = [[UIButton alloc] initWithFrame:CGRectMake(618, 300, 150, 40)];
        [cancelAnnotation setTitle:@"Cancel" forState:UIControlStateNormal];
        [cancelAnnotation setBackgroundColor:[UIColor whiteColor]];
        [cancelAnnotation setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [cancelAnnotation addTarget:self action:@selector(cancelAnnotation:) forControlEvents:UIControlEventTouchDown];
        [newAnnotationWindow addSubview:newTitle];
        [newAnnotationWindow addSubview:newBody];
        [newAnnotationWindow addSubview:addAnnotation];
        [newAnnotationWindow addSubview:cancelAnnotation];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    int count = [polygonAnnotations count];
    for (int i = 0; i < count; ++i) {
        [[UIColor yellowColor] setStroke];
        [[UIColor yellowColor] setFill];
        UIBezierPath *path = [polygonAnnotations objectAtIndex:i];
        if (currentTouch && state == NotDrawing) {
            if ([self containsPoint:[currentTouch locationInView:self] onPath:path inFillArea:true]) {
                if ([polygonTitle count] > i) {
                    [titleView setText:[polygonTitle objectAtIndex:i]];
                } else {
                    [titleView setText:@"No annotation title."];
                }
                if ([polygonText count] > i) {
                    [bodyView setText:[polygonText objectAtIndex:i]];
                } else {
                    [bodyView setText:@"No annotation body."];
                }
                [[self parentView] addSubview:annotationInfo];
                [[UIColor blueColor] setStroke];
                [[UIColor blueColor] setFill];
            }
        } else {
            [annotationInfo removeFromSuperview];
        }
        [path setLineWidth:1.5/scaling];
        [path stroke];
        [path fillWithBlendMode:kCGBlendModeNormal alpha:0.1];
    }
}

- (void)loadAnnotations:(NSString*)mapID
{
    NSString *url = [NSString stringWithFormat:@"http://128.253.195.81:8080/de.vogella.jersey.first/rest/MapHub/Maps/%@/annotations", mapID];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *receivedData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:receivedData];
    [parser setDelegate:self];
    [parser parse];
    [self setNeedsDisplay];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
    if ([elementName isEqualToString:@"annotation"]) {
    } else if ([elementName isEqualToString:@"body"]) {
        parsingState = BODY;
    } else if ([elementName isEqualToString:@"title"]) {
        parsingState = TITLE;
    } else if ([elementName isEqualToString:@"wkt-data"]) {
        parsingState = DATA;
    }
}
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    if([string hasPrefix:@"\n"] || [string hasSuffix:@"\n"]) return;
    NSString *text;
    NSScanner *scanner = [NSScanner scannerWithString:string];
    CGPoint point;
    switch (parsingState) {
        case BODY:
            text = [[NSString alloc] initWithString:string];
            [polygonText addObject:text];
            break;
        case TITLE:
            text = [[NSString alloc] initWithString:string];
            [polygonTitle addObject:text];
            break;
        case DATA:
            currentPath = [UIBezierPath bezierPath];
            while ([scanner isAtEnd] == NO) {
                if ([scanner scanFloat:&(point.x)]) {
                    [scanner scanFloat:&(point.y)];
                    if ([currentPath isEmpty]) {
                        [currentPath moveToPoint:point];
                    } else {
                        [currentPath addLineToPoint:point];
                    }
                } else {
                    [scanner setScanLocation:([scanner scanLocation] + 1)];
                }
            }
            [currentPath closePath];
            [polygonAnnotations addObject:currentPath];
            break;
        default:
            break;
    }
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    parsingState = ANNOTATION;
    if ([elementName isEqualToString:@"annotation"]) {
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if(touches.count > 1) return;
    if(currentTouch) return;
    if(state == BezierStateNone) {
        currentTouch = [touches anyObject];
        state = BezierStateDefiningLine;
        currentPath = [UIBezierPath bezierPath];
        [polygonAnnotations addObject:currentPath];
        [currentPath moveToPoint:[currentTouch locationInView:self]];
        [self setNeedsDisplay];
    }
    else if(state == BezierStateDefiningLine){
        currentTouch = [touches anyObject];
        [currentPath addLineToPoint:[currentTouch locationInView:self]];
        if([[touches anyObject] tapCount] > 1){
            [currentPath closePath];
            state = BezierStateNone;
            [newTitle setText:@"Title"];
            [newBody setText:@"Body"];
            [[self parentView] addSubview:newAnnotationWindow];
            
            /*CGPoint loc = [currentTouch locationInView:self];
            UITextView *annotation = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 200, 80)];
            [annotation setTransform:CGAffineTransformMakeScale(1/scaling, 1/scaling)];
            [annotation setCenter:loc];
            [annotation setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:255 alpha:0.2]];
            [self addSubview:annotation];*/
        }
        [self setNeedsDisplay];
    } else if(state == NotDrawing){
        currentTouch = [touches anyObject];
        [self setNeedsDisplay];
    }
}

- (void)addAnnotation:(id)sender
{
    [polygonTitle addObject:[NSString stringWithString:[newTitle text]]];
    [polygonText addObject:[NSString stringWithString:[newBody text]]];
    [newAnnotationWindow removeFromSuperview];
}

- (void)cancelAnnotation:(id)sender
{
    [polygonAnnotations removeObject:currentPath];
    [newAnnotationWindow removeFromSuperview];
    [self setNeedsDisplay];
}

- (BOOL)containsPoint:(CGPoint)point onPath:(UIBezierPath*)path inFillArea:(BOOL)inFill
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGPathRef cgPath = path.CGPath;
    BOOL    isHit = NO;
    
    // Determine the drawing mode to use. Default to
    // detecting hits on the stroked portion of the path.
    CGPathDrawingMode mode = kCGPathStroke;
    if (inFill)
    {
        // Look for hits in the fill area of the path instead.
        if (path.usesEvenOddFillRule)
            mode = kCGPathEOFill;
        else
            mode = kCGPathFill;
    }
    
    // Save the graphics state so that the path can be
    // removed later.
    CGContextSaveGState(context);
    CGContextAddPath(context, cgPath);
    
    // Do the hit detection.
    isHit = CGContextPathContainsPoint(context, point, mode);
    
    CGContextRestoreGState(context);
    
    return isHit;
}
         
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if(!currentTouch) return;
    currentTouch = nil;
    [self setNeedsDisplay];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!currentTouch) return;
    currentTouch = nil;
    [self setNeedsDisplay];
}

/*
 - (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
 if(!currentTouch) return;
 if(state == BezierStateDefiningLine) {
 endPt = [currentTouch locationInView:self];
 } else if(state == BezierStateDefiningCP1) {
 cPt1 = [currentTouch locationInView:self];
 } else if(state == BezierStateDefiningCP2) {
 cPt2 = [currentTouch locationInView:self];
 }
 }
 - (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
 if(!currentTouch) return;
 if(state == BezierStateDefiningLine) {
 state = BezierStateDefiningCP1;
 } else if(state == BezierStateDefiningCP1) {
 state = BezierStateDefiningCP2;
 } else if(state == BezierStateDefiningCP2) {
 state = BezierStateNone;
 }
 currentTouch = nil;
 }
 - (void)touchesCanceled:(NSSet *)touches withEvent:(UIEvent *)event {
 if(state == BezierStateDefiningLine) {
 self.curvePath = nil;
 self.state = BezierStateNone;
 }
 self.currentTouch = nil;
 }
 - (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
 if (currentTouch) return;
 currentTouch = [touches anyObject]; 
 if (pathInit) {
 UIBezierPath *newAnnotation = [UIBezierPath bezierPath];
 [polygonAnnotations addObject:newAnnotation];
 [newAnnotation moveToPoint:[currentTouch locationInView:self]];
 //[newAnnotation release];
 pathInit = false;
 } else {
 UIBezierPath *currentAnnotation = [polygonAnnotations lastObject];
 [currentAnnotation addLineToPoint:[currentTouch locationInView:self]];
 [currentAnnotation stroke];
 //[currentAnnotation release];
 }
 }
 
 - (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
 if(!currentTouch) return;
 if(state == BezierStateDefiningLine) {
 endPt = [currentTouch locationInView:self];
 [self _calcDefaultControls];
 [self _updateCurve];
 } else if(state == BezierStateDefiningCP1) {
 cPt1 = [currentTouch locationInView:self];
 [self _updateCurve];
 } else if(state == BezierStateDefiningCP2) {
 cPt2 = [currentTouch locationInView:self];
 [self _updateCurve];
 }
 }
 */
/*
- (void)touchesCanceled:(NSSet *)touches withEvent:(UIEvent *)event {
    if(state == BezierStateDefiningLine) {
        self.curvePath = nil;
        self.state = BezierStateNone;
    }
    self.currentTouch = nil;
}
*/
@end
