//
//  ImageAndTextCell.h
//
//  Copyright (c) 2001-2002, Apple. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ImageAndTextCell : NSTextFieldCell {
@private
    NSImageCell *imageCell;
}

@end