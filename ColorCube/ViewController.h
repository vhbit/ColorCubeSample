//
//  ViewController.h
//  ColorCube
//
//  Created by Valerii Hiora on 07/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
{
    __weak IBOutlet UISlider *minHueSlider;
    __weak IBOutlet UISlider *maxHueSlider;
    __weak IBOutlet UILabel *minHueLabel;
    __weak IBOutlet UILabel *maxHueLabel;
    __weak IBOutlet UIImageView *previewImageView;
}
- (IBAction)maxHueChanged:(id)sender;
- (IBAction)minHueChanged:(id)sender;
@end