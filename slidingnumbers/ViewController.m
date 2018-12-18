//
//  ViewController.m
//  slidingnumbers
//
//  Created by Jason on 8/24/18.
//  Copyright © 2018 Jason Ngov. All rights reserved.
//

#import "ViewController.h"
#import <AudioToolbox/AudioServices.h>

@interface ViewController ()

@end


@implementation ViewController
@synthesize button1, button2, button3, button4, button5, button6, button7, button8, button9, button10, button11, button12, button13, button14, button15, startButton, resetButton, Grid, moveLabel, timeLabel, winLabel, pauseButton;

NSMutableArray* buttons;
NSMutableArray* trackRandoms;
NSTimer* timer;
NSArray* indexArray;
//tracks user selection in one dimensional array
NSMutableArray* oneDimArray;
NSMutableArray* defaultDimArray;

int numStartPressed, numMoves, count, firstButtonIndex;
int buttonRow, buttonCol, zeroRow, zeroCol;
BOOL pauseButtonIsPressed = true;
BOOL firstButtonPressed = true;

int userMatrix [4][4] = {
    {1, 2, 3, 4},
    {5, 6, 7, 8},
    {9, 10, 11, 12},
    {13, 14, 15, 0}
};

//default matrix userMatrix is compared to
int matrix [4][4] = {
    {1, 2, 3, 4},
    {5, 6, 7, 8},
    {9, 10, 11, 12},
    {13, 14, 15, 0}
};

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //format labels
    moveLabel.clipsToBounds = YES;
    moveLabel.layer.cornerRadius = 3;
    timeLabel.clipsToBounds = YES;
    timeLabel.layer.cornerRadius = 3;
    
    //pre-information regarding timeLabel
    timeLabel.text = [@"Time \n" stringByAppendingString: @"00:00"];
    count = 0;
    
    //sets default value for moveLabel
    numMoves = 0;
    [moveLabel setText:[@"Moves \n" stringByAppendingString:[NSString stringWithFormat:@"%d", numMoves]]];
    
    //initializes counter for the number of times start button is pressed
    numStartPressed = 0;
    
    
    //initialize and create space for NSMutable one dimensional array
    oneDimArray = [[NSMutableArray alloc] init];
    defaultDimArray = [[NSMutableArray alloc] init];
    
    //fills defaultDimArray with NSNumbers between 0-15
    for (int i = 0; i < 15; i++){
        defaultDimArray[i] = [NSNumber numberWithInt: i + 1];
    }
    [defaultDimArray addObject: [NSNumber numberWithInt: 0]];
    
    //initializes and fills array with buttons
    buttons = [NSMutableArray arrayWithObjects:button1, button2,button3,button4,button5,button6,button7,button8,button9,button10,button11,button12,button13,button14,button15, nil];
    
    //fills NSArray of the locations of each button
    indexArray = [NSMutableArray arrayWithObjects:
                  [NSValue valueWithCGRect:CGRectMake(20, 161, 80, 80)], //button1 default, randomInt = 0
                  [NSValue valueWithCGRect:CGRectMake(105, 161, 80, 80)], //button2 default, randomInt = 1
                  [NSValue valueWithCGRect:CGRectMake(190, 161, 80, 80)], //button3 default, randomInt = 2
                  [NSValue valueWithCGRect:CGRectMake(275, 161, 80, 80)], //button4 default, randomInt = 3
                  [NSValue valueWithCGRect:CGRectMake(20, 246, 80, 80)], //button5 default, randomInt = 4
                  [NSValue valueWithCGRect:CGRectMake(105, 246, 80, 80)], //button6 default, randomInt = 5
                  [NSValue valueWithCGRect:CGRectMake(190, 246, 80, 80)], //button7 default, randomInt = 6
                  [NSValue valueWithCGRect:CGRectMake(275, 246, 80, 80)], //button8 default, randomInt = 7
                  [NSValue valueWithCGRect:CGRectMake(20, 331, 80, 80)], //button9 default, randomInt = 8
                  [NSValue valueWithCGRect:CGRectMake(105, 331, 80, 80)], //button10 default, randomInt = 9
                  [NSValue valueWithCGRect:CGRectMake(190, 331, 80, 80)], //button11 default, randomInt = 10
                  [NSValue valueWithCGRect:CGRectMake(275, 331, 80, 80)], //button12 default, randomInt = 11
                  [NSValue valueWithCGRect:CGRectMake(20, 416, 80, 80)], //button13 default, randomInt = 12
                  [NSValue valueWithCGRect:CGRectMake(105, 416, 80, 80)], //button14 default, randomInt = 13
                  [NSValue valueWithCGRect:CGRectMake(190, 416, 80, 80)],//button 15 default, randomInt = 14
                  nil];
    
    //disables buttons
    for (UIButton *btn in buttons){
        [btn setEnabled: false];
    }
    [pauseButton setEnabled: false];
    
    //hides winLabel
    [winLabel setHidden: YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)startButtonPressed:(id)sender {
    numMoves = 0;

    //enables buttons
    for (UIButton *btn in buttons){
        [btn setEnabled: true];
    }

    //disables and hides startButton
    [startButton setHidden: YES];
    
    //empties trackRandom array and randomizes button tiles
    [trackRandoms removeAllObjects];
    [self randomizeTiles];
    userMatrix[3][3] = 0;
    
}

- (IBAction)resetButtonPressed:(id)sender {
    //enables and redisplays startButton
    [startButton setHidden: NO];
    
    [pauseButton setEnabled: false];
    [pauseButton setTitle: @"Pause" forState: UIControlStateNormal];
    pauseButtonIsPressed = true;
    
    //resets movelabel
    numMoves = 0;
    [moveLabel setText:[@"Moves \n" stringByAppendingString:[NSString stringWithFormat:@"%d", numMoves]]];
    
    //resets timer
    [timer invalidate];
    timer = nil;
    timeLabel.text = [@"Time \n" stringByAppendingString: @"00:00"];
    count = 0;
    
    
    //resets tiles
    [self resetTiles];
    
    //disables buttons
    for (UIButton *btn in buttons){
        [btn setEnabled: false];
        btn.alpha = 1;
    }

    firstButtonPressed = true; //starts timer when firstButton pressed
    [winLabel setHidden:YES]; //winLabel hidden
    firstButtonIndex = 0;
    
    
}


- (IBAction)buttonPressed:(id)sender {
    UIButton* btn = (UIButton*)(id)sender;
    int btnTag = (int)[btn tag];
    
    //parses matrix to look for location of buttonPressed
    for (int row = 0; row < 4; row++){
        for (int col = 0; col < 4; col++){
            if (userMatrix[row][col] == btnTag){
                buttonRow = row;
                buttonCol = col;
            }
        }
    }
    
    //parses matrix to look for location of zero
    for (int row = 0; row < 4; row++){
        for (int col = 0; col < 4; col++){
            if (userMatrix[row][col] == 0){
                zeroRow = row;
                zeroCol = col;
            }
        }
    }
    
    //conditions
    if (buttonRow == zeroRow){
        if(zeroCol - buttonCol == 1){
            [self startTimer];
            numMoves++;
            
            [UIView animateWithDuration: 0.5 animations: ^{
                btn.frame = CGRectOffset(btn.frame, 85, 0);
            }];
            userMatrix[buttonRow][buttonCol] = 0;
            userMatrix[zeroRow][zeroCol] = btnTag;
            
        } else if (buttonCol - zeroCol == 1) {
            [self startTimer];
            numMoves++;
            
            [UIView animateWithDuration: 0.5 animations: ^{
                btn.frame = CGRectOffset(btn.frame, -85, 0);
            }];
            userMatrix[buttonRow][buttonCol] = 0;
            userMatrix[zeroRow][zeroCol] = btnTag;
        } else {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        }
    } else if (buttonCol == zeroCol){
        if (buttonRow - zeroRow == 1){
            [self startTimer];
            numMoves++;
            
            //moves button to the top
            [UIView animateWithDuration: 0.5 animations: ^{
                btn.frame = CGRectOffset(btn.frame, 0, -85);
            }];
            userMatrix[buttonRow][buttonCol] = 0;
            userMatrix[zeroRow][zeroCol] = btnTag;
            
        } else if (zeroRow - buttonRow == 1){
            [self startTimer];
            numMoves++;
            
            //moves button to the bottom
            [UIView animateWithDuration:0.5 animations:^{
                btn.frame = CGRectOffset(btn.frame, 0, 85);
            }];
            userMatrix[buttonRow][buttonCol] = 0;
            userMatrix[zeroRow][zeroCol] = btnTag;
        } else {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        }
    } else {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
    
    //update move label
    [moveLabel setText:[@"Moves \n" stringByAppendingString:[NSString stringWithFormat:@"%d", numMoves]]];
    
    
    /* FOR DEBUGGING
     * prints real-time elements in matrix
    for (int row = 0; row < 4; row++){
        printf(" (");
        for (int col = 0; col < 4; col++){
            printf("%d ", userMatrix[row][col]);
        }
        printf(")\n");
    }
    */
    
    //loads user selections into a one dimensional matrix to be compared with default matrix
    int i = 0;
    for (int row = 0; row < 4; row++){
        for (int col = 0; col < 4; col++){
            oneDimArray[i] = [NSNumber numberWithInt: userMatrix[row][col]];
            i++;
        }
    }
    [self compareMatrix]; //compares matrix between userMatrix and default matrix
}

- (IBAction)pauseButtonPressed:(id)sender {
    if(pauseButtonIsPressed){
        for (UIButton* btn in buttons){
            btn.alpha = 0.6;
            [btn setEnabled: NO];
        }
        [winLabel setText:@"Paused"];
        [winLabel setHidden: NO];
        [pauseButton setTitle:@"Resume" forState:UIControlStateNormal];
        pauseButtonIsPressed = false;
        [timer invalidate];
        timer = nil;
    } else {
        for (UIButton* btn in buttons){
            btn.alpha = 1;
            [btn setEnabled: YES];
        }
        [winLabel setHidden: YES];
        [pauseButton setTitle: @"Pause" forState:UIControlStateNormal];
        pauseButtonIsPressed = true;
        [self countdown];
    }

}
- (void) randomizeTiles {
    NSMutableArray* randLoc = [indexArray mutableCopy];
    trackRandoms = [[NSMutableArray alloc] initWithCapacity: 0];
    int x, y;
    
    //randomizes position of UIButtons
    for (int i = 0; i < [buttons count]; i++){
        UIButton* btn = buttons[i];
        int randomInt = arc4random() % [randLoc count];
        
        //checks to see if randomInt obj is in trackRandoms, will randomize once more if so
        if (![trackRandoms containsObject:[NSNumber numberWithInt: randomInt]]){
            [trackRandoms addObject: [NSNumber numberWithInt: randomInt]];
        } else {
            randomInt = arc4random() % [randLoc count];
            [trackRandoms addObject: [NSNumber numberWithInt: randomInt]];
        }
        
        //gives specific coordinates for where btn should be replaced
        btn.frame = [[randLoc objectAtIndex: randomInt] CGRectValue];
        x = btn.frame.origin.x; //x position of tile
        y = btn.frame.origin.y; //y position of tile
        
        
        //following switch cases manually updates the matrix in acccordance with random button
        switch(x)
        {
            case 20:
                buttonCol = 0;
                break;
            case 105:
                buttonCol = 1;
                break;
            case 190:
                buttonCol = 2;
                break;
            case 275:
                buttonCol = 3;
                break;
        }
        
       switch(y)
        {
            case 161:
                buttonRow = 0;
                break;
            case 246:
                buttonRow = 1;
                break;
            case 331:
                buttonRow = 2;
                break;
            case 416:
                buttonRow = 3;
                break;
        }
        
        //updates matrix with new position of button
        userMatrix [buttonRow][buttonCol] = (int)[btn tag];
        
        //sets background color to beige, and resets title color
        [btn setBackgroundColor:[UIColor colorWithRed:238./255. green:228./255. blue:218./255. alpha:1]];
        [btn setTitleColor: [UIColor colorWithRed: 115./255. green: 106./255. blue: 97/255. alpha: 1] forState:UIControlStateNormal];
    
        //removes object from randLoc so there is no repeated index and overlap between tiles
        [randLoc removeObjectAtIndex: randomInt];
    }
    
}

- (void) compareMatrix {
    /* FOR DEBUGGING
     * prints elements inside defaultDimArray and oneDimArray
    
    for (int i = 0; i < [defaultDimArray count]; i++){
     NSLog(@"%@ Default Array: ", defaultDimArray[i]);
    }
    
    for (int i = 0; i < [oneDimArray count]; i++){
     NSLog(@"%@ User Array: ", [@"%d ," stringByAppendingString:[NSString stringWithFormat: @"%@", oneDimArray[i]]]);
    }
     */
    if ([oneDimArray isEqual: defaultDimArray]){
        for (UIButton* btn in buttons){
            btn.alpha = 0.6;
            [btn setEnabled:NO];
        }
        [winLabel setHidden: NO];
        [winLabel setText: @"You Win!"];
        [timer invalidate];
        
    }
}

- (void) countdown {
    timer = [NSTimer scheduledTimerWithTimeInterval: 0.01 target: self selector: @selector(updateTimer) userInfo: nil repeats: YES];
}

- (void) updateTimer {
    count++;
    int min = floor(count/100/60);
    int sec = floor(count/100);
    
    if (sec >= 60){
        sec = sec % 60;
    }
    
    timeLabel.text = [@"Time \n" stringByAppendingString: [NSString stringWithFormat:@"%02d:%02d", min, sec]];
    
}

- (void) resetTiles {
    for (int i = 0; i < [buttons count]; i++){
        UIButton* btn = buttons[i];
        btn.frame = [indexArray[i] CGRectValue];
    }
}
- (void) startTimer {
    //starts timer when firstButtonPressed
    if (firstButtonPressed){
        if (firstButtonIndex == 0){
            [self countdown];
            firstButtonIndex++;
            [pauseButton setEnabled: YES];
            firstButtonPressed = false;
        }
    }
}
@end
