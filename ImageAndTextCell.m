
#import "ImageAndTextCell.h"

@implementation ImageAndTextCell

- (id)initTextCell:(NSString *)aString
{
    self = [super initTextCell:aString];
    imageCell = [[NSImageCell alloc] init];
    [imageCell setImageScaling:NSImageScaleProportionallyDown];
    [imageCell setImageAlignment:NSImageAlignBottom];
    return self;
}

- (void)dealloc {
    [imageCell release];
    [super dealloc];
}

- copyWithZone:(NSZone *)zone {
    ImageAndTextCell *cell = (ImageAndTextCell *)[super copyWithZone:zone];
    cell->imageCell = [imageCell retain];
    return cell;
}

- (void)setImage:(NSImage *)anImage {
    [imageCell setImage:anImage];
}

- (NSImage *)image {
    return [imageCell image];
}

- (NSRect)imageFrameForCellFrame:(NSRect)cellFrame {
    NSImage *image = [self image];
    if (image != nil) {
        NSRect imageFrame;
        imageFrame.size = [image size];
        imageFrame.origin = cellFrame.origin;
        imageFrame.origin.x += 3;
        imageFrame.origin.y += ceil((cellFrame.size.height - imageFrame.size.height) / 2);
        return imageFrame;
    }
    else
        return NSZeroRect;
}

- (void)editWithFrame:(NSRect)aRect inView:(NSView *)controlView editor:(NSText *)textObj delegate:(id)anObject event:(NSEvent *)theEvent {
    NSRect textFrame, imageFrame;
    NSDivideRect (aRect, &imageFrame, &textFrame, 3 + [[self image] size].width, NSMinXEdge);
    [super editWithFrame: textFrame inView: controlView editor:textObj delegate:anObject event: theEvent];
}

- (void)selectWithFrame:(NSRect)aRect inView:(NSView *)controlView editor:(NSText *)textObj delegate:(id)anObject start:(NSInteger)selStart length:(NSInteger)selLength {
    NSRect textFrame, imageFrame;
    NSDivideRect (aRect, &imageFrame, &textFrame, 3 + [[self image] size].width, NSMinXEdge);
    [super selectWithFrame: textFrame inView: controlView editor:textObj delegate:anObject start:selStart length:selLength];
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
    NSImage *image = [self image];
    if (image != nil) {
        NSSize	imageSize;
        NSRect	imageFrame;

        imageSize = [image size];
        NSDivideRect(cellFrame, &imageFrame, &cellFrame, 3 + imageSize.width, NSMinXEdge);
        if ([self drawsBackground]) {
            [[self backgroundColor] set];
            NSRectFill(imageFrame);
        }
        imageFrame.origin.x += 3;
        imageFrame.size = imageSize;
        imageFrame.origin.y += ceil((cellFrame.size.height - imageFrame.size.height) / 2);

        [imageCell drawWithFrame:imageFrame inView:controlView];
    }
    [super drawWithFrame:cellFrame inView:controlView];
}

- (NSSize)cellSize {
    NSSize cellSize = [super cellSize];
    NSImage *image = [self image];
    cellSize.width += (image ? [image size].width : 0) + 3;
    return cellSize;
}

@end