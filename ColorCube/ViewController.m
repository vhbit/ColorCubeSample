//
//  ViewController.m
//  ColorCube
//
//  Created by Valerii Hiora on 07/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

//void rgbToHSV(float rgb[3], float **hsv);

void rgbToHSV(float rgb[3], float hsv[3])
{
    float min, max, delta;
    float r = rgb[0], g = rgb[1], b = rgb[2];
    //float *h = hsv[0], *s = hsv[1], *v = hsv[2];

    min = MIN( r, MIN( g, b ));
    max = MAX( r, MAX( g, b ));
    hsv[2] = max;               // v
    delta = max - min;
    if( max != 0 )
        hsv[1] = delta / max;       // s
    else {
        // r = g = b = 0        // s = 0, v is undefined
        hsv[1] = 0;
        hsv[0] = -1;
        return;
    }
    if( r == max )
        hsv[0] = ( g - b ) / delta;     // between yellow & magenta
    else if( g == max )
        hsv[0] = 2 + ( b - r ) / delta; // between cyan & yellow
    else
        hsv[0] = 4 + ( r - g ) / delta; // between magenta & cyan
    hsv[0] *= 60;               // degrees
    if( hsv[0] < 0 )
        hsv[0] += 360;
    hsv[0] /= 360.0;
}

void hsvToRGB(float hsv[3], float rgb[3])
{
    float C = hsv[2] * hsv[1];
    float HS = hsv[0] * 6.0;
    float X = C * (1.0 - fabsf(fmodf(HS, 2.0) - 1.0));

    if (HS >= 0 && HS < 1)
    {
        rgb[0] = C;
        rgb[1] = X;
        rgb[2] = 0;
    }
    else if (HS >= 1 && HS < 2)
    {
        rgb[0] = X;
        rgb[1] = C;
        rgb[2] = 0;
    }
    else if (HS >= 2 && HS < 3)
    {
        rgb[0] = 0;
        rgb[1] = C;
        rgb[2] = X;
    }
    else if (HS >= 3 && HS < 4)
    {
        rgb[0] = 0;
        rgb[1] = X;
        rgb[2] = C;
    }
    else if (HS >= 4 && HS < 5)
    {
        rgb[0] = X;
        rgb[1] = 0;
        rgb[2] = C;
    }
    else if (HS >= 5 && HS < 6)
    {
        rgb[0] = C;
        rgb[1] = 0;
        rgb[2] = X;
    }
    else {
        rgb[0] = 0.0;
        rgb[1] = 0.0;
        rgb[2] = 0.0;
    }


    float m = hsv[2] - C;
    rgb[0] += m;
    rgb[1] += m;
    rgb[2] += m;
}


@implementation ViewController
{
    UIImage *_inputImage;
    CIImage *_ciImage;
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    _inputImage = [UIImage imageNamed:@"test.jpg"];
    _ciImage = [[CIImage alloc] initWithCGImage:_inputImage.CGImage];

    [self render];
}

- (void)viewDidUnload
{
    minHueSlider = nil;
    maxHueSlider = nil;
    minHueLabel = nil;
    maxHueLabel = nil;
    previewImageView = nil;

    [super viewDidUnload];
}

- (void)render
{
    float minHueAngle = minHueSlider.value;
    float maxHueAngle = maxHueSlider.value;
    float centerHueAngle = minHueAngle + (maxHueAngle - minHueAngle)/2.0;
    float destCenterHueAngle = 1.0/3.0;

    const unsigned int size = 64;
    size_t cubeDataSize = size * size * size * sizeof ( float ) * 4;
    float *cubeData = (float *) malloc ( cubeDataSize );
    float rgb[3], hsv[3], newRGB[3];

    size_t offset = 0;
    for (int z = 0; z < size; z++)
    {
        rgb[2] = ((double) z) / size; // blue value
        for (int y = 0; y < size; y++)
        {
            rgb[1] = ((double) y) / size; // green value
            for (int x = 0; x < size; x++)
            {
                rgb[0] = ((double) x) / size; // red value
                rgbToHSV(rgb, hsv);

                if (hsv[0] < minHueAngle || hsv[0] > maxHueAngle)
                    memcpy(newRGB, rgb, sizeof(newRGB));
                else
                {
                    hsv[0] = destCenterHueAngle + (centerHueAngle - hsv[0]);
                    hsvToRGB(hsv, newRGB);
                }

                cubeData[offset]   = newRGB[0];
                cubeData[offset+1] = newRGB[1];
                cubeData[offset+2] = newRGB[2];
                cubeData[offset+3] = 1.0;

                offset += 4;
            }
        }
    }

    NSData *data = [NSData dataWithBytesNoCopy:cubeData length:cubeDataSize freeWhenDone:YES];
    CIFilter *colorCube = [CIFilter filterWithName:@"CIColorCube"];
    [colorCube setValue:[NSNumber numberWithInt:size] forKey:@"inputCubeDimension"];
    [colorCube setValue:data forKey:@"inputCubeData"];
    [colorCube setValue:_ciImage forKey:kCIInputImageKey];

    CIImage *outImage = colorCube.outputImage;
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef outputImageRef = [context createCGImage:outImage fromRect:[outImage extent]];
    previewImageView.image = [UIImage imageWithCGImage:outputImageRef];
}

- (IBAction)maxHueChanged:(id)sender
{
    maxHueLabel.text = [NSString stringWithFormat:@"%.2lf", maxHueSlider.value];
    [self render];
}

- (IBAction)minHueChanged:(id)sender
{
    minHueLabel.text = [NSString stringWithFormat:@"%.2lf", minHueSlider.value];
    [self render];
}
@end