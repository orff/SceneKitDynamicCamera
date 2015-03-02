//
//  GameViewController.m
//  DeviceCameraTest
//
//  Created by Michael Hill on 3/1/15.
//  Copyright (c) 2015 Michael Hill. All rights reserved.
//

#import "GameViewController.h"

@implementation GameViewController

#define NORMAL_CAMERA_HEIGHT    45

-(void)cameraPositionForLevelSize {
    SCNView *sceneView = (SCNView *)self.view;
    SCNNode *cameraNode = [[sceneView.scene rootNode] childNodeWithName:@"cameraNode" recursively:NO];
    SCNCamera *camera = cameraNode.camera;
    
    float cameraHeight = NORMAL_CAMERA_HEIGHT;
    float normalFOV = 30;
    
    float width = boxWidth*1.1;
    float height = boxHeight*1.1;
    
    if (width > height) {
        camera.xFov = normalFOV;
        camera.yFov = 0;
        
        float theta = (camera.xFov / 2.0) * (M_PI / 180.0);
        cameraHeight = (width / 2.0) / tan(theta);
    } else {
        camera.xFov = 0;
        camera.yFov = normalFOV;
        
        float theta = (camera.yFov / 2.0) * (M_PI / 180.0);
        cameraHeight = (height / 2.0) / tan(theta);
    }
    NSLog(@"w: %2f h: %2f camZ: %2f", boxWidth, boxHeight, cameraHeight);
    
    SCNAction *newCamPos = [SCNAction moveTo:SCNVector3Make(0, 0, cameraHeight) duration:0.3];
    [cameraNode runAction:newCamPos];
//    cameraNode.position = SCNVector3Make(0, 0, cameraHeight + 5.0);
}

-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    NSLog(@"gamectroller new size! W: %2f H: %2f", size.width, size.height);
    
    //only call once it is finished changing size!
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        //
        [self cameraPositionForLevelSize];
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        //
        
    }];
}

-(void)newBox {
    SCNView *sceneView = (SCNView *)self.view;
    SCNNode *boxNode = [[sceneView.scene rootNode] childNodeWithName:@"boxNode" recursively:NO];
    
    boxWidth = arc4random_uniform(45) + 5.0;
    boxHeight = arc4random_uniform(45) + 5.0;
    
    SCNBox *theBox = [SCNBox boxWithWidth:boxWidth height:boxHeight length:5 chamferRadius:0.1];
    [boxNode removeFromParentNode];
    
    SCNNode *theBoxNode = [SCNNode nodeWithGeometry:theBox];
    theBoxNode.name = @"boxNode";
    
    [sceneView.scene.rootNode addChildNode:theBoxNode];
    
    // animate the 3d object
    //[theBoxNode runAction:[SCNAction repeatActionForever:[SCNAction rotateByX:0 y:2 z:0 duration:1]]];
    
    [self cameraPositionForLevelSize];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // create a new scene
    SCNScene *scene = [SCNScene scene];

    // create and add a camera to the scene
    SCNNode *cameraNode = [SCNNode node];
    cameraNode.name = @"cameraNode";
    cameraNode.camera = [SCNCamera camera];
    cameraNode.camera.zFar = 250;
    [scene.rootNode addChildNode:cameraNode];
    
    // place the camera
    cameraNode.position = SCNVector3Make(0, 0, NORMAL_CAMERA_HEIGHT);
    
    // create and add a light to the scene
    SCNNode *lightNode = [SCNNode node];
    lightNode.light = [SCNLight light];
    lightNode.light.type = SCNLightTypeOmni;
    lightNode.position = SCNVector3Make(0, 10, 10);
    [scene.rootNode addChildNode:lightNode];
    
    // create and add an ambient light to the scene
    SCNNode *ambientLightNode = [SCNNode node];
    ambientLightNode.light = [SCNLight light];
    ambientLightNode.light.type = SCNLightTypeAmbient;
    ambientLightNode.light.color = [UIColor darkGrayColor];
    [scene.rootNode addChildNode:ambientLightNode];
    
    // retrieve the SCNView
    SCNView *scnView = (SCNView *)self.view;
    
    // set the scene to the view
    scnView.scene = scene;
    
    // allows the user to manipulate the camera
    //scnView.allowsCameraControl = YES;
        
    // show statistics such as fps and timing information
    //scnView.showsStatistics = YES;

    // configure the view
    scnView.backgroundColor = [UIColor blackColor];
    
    [self newBox];
    
    // add a tap gesture recognizer
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    NSMutableArray *gestureRecognizers = [NSMutableArray array];
    [gestureRecognizers addObject:tapGesture];
    [gestureRecognizers addObjectsFromArray:scnView.gestureRecognizers];
    scnView.gestureRecognizers = gestureRecognizers;
}

- (void) handleTap:(UIGestureRecognizer*)gestureRecognize
{
    // retrieve the SCNView
    SCNView *scnView = (SCNView *)self.view;
    
    // check what nodes are tapped
    CGPoint p = [gestureRecognize locationInView:scnView];
    NSArray *hitResults = [scnView hitTest:p options:nil];
    
    // check that we clicked on at least one object
    if([hitResults count] > 0) {
        [self newBox];
    }
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

@end
