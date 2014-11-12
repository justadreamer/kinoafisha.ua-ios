//
//  AttributeCell.m
//  kinoafisha
//
//  Created by Eugene Dorfman on 11/12/14.
//  Copyright (c) 2014 justadreamer. All rights reserved.
//

#import "AttributeCell.h"
#import "Attribute.h"
@interface AttributeCell()
@property (nonatomic,strong) IBOutlet UILabel *nameLabel;
@property (nonatomic,strong) IBOutlet UILabel *valueLabel;
@end
@implementation AttributeCell

- (void) setAttribute:(Attribute *)attribute {
    _attribute = attribute;
    self.nameLabel.text = attribute.name;
    self.valueLabel.text = attribute.value;
}
@end
