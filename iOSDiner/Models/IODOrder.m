//
//  IODOrder.m
//  iOSDiner
//
//  Created by Adam Burkepile on 1/29/12.
//  Copyright (c) 2012 Adam Burkepile. All rights reserved.
//

#import "IODOrder.h"
#import "IODItem.h"

@implementation IODOrder
@synthesize orderItems;

- (IODItem*)findKeyForOrderItem:(IODItem*)searchItem {
    NSIndexSet* indexes = [[[self getOrderItems] allKeys] indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        IODItem* key = obj;
        
        return [[searchItem name] isEqualToString:[key name]] && 
        fabsf([searchItem price] - [key price])<0.01;
    }];
    
    if ([indexes count] >= 1) {
        IODItem* key = [[[self getOrderItems] allKeys] objectAtIndex:[indexes firstIndex]];
        return key;
    }
    
    return nil;
}

- (NSMutableDictionary *)getOrderItems{
    if (!orderItems) {
        orderItems = [NSMutableDictionary new];
    }
    
    return orderItems;
}

- (NSString*)orderDescription {
    NSMutableString* orderDescription = [NSMutableString new];
    
    NSArray* keys = [[[self getOrderItems] allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        IODItem* item1 = (IODItem*)obj1;
        IODItem* item2 = (IODItem*)obj2;
        
        return [[item1 name] compare:[item2 name]];
    }];
    
    [keys enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        IODItem* item = (IODItem*)obj;
       // NSNumber* quantity = (NSNumber*)[[self getOrderItems] objectForKey:item];
        IODItem* key =[self   findKeyForOrderItem:item];
         NSNumber* quantity = (NSNumber*)[[self getOrderItems] objectForKey:key];
        NSLog(@"%@,%d,%@",obj,idx,quantity);
        [orderDescription appendFormat:@"%@ x%d\n",[item name],[quantity intValue]];
    }];
    NSLog(@"All contents: %@", [self getOrderItems]);

    return [orderDescription copy];
}

- (void)addItemToOrder:(IODItem*)inItem {
    IODItem* key = [self findKeyForOrderItem:inItem];
    
    if (!key) {
        [[self getOrderItems] setObject:[NSNumber numberWithInt:1] forKey:inItem];
    }
    else {
        NSNumber* quantity = [[self getOrderItems] objectForKey:key];
        int intQuantity = [quantity intValue];
        intQuantity++;
        
        //[[self getOrderItems] removeObjectForKey:key];
        [[self getOrderItems] setObject:[NSNumber numberWithInt:intQuantity] forKey:key];
    }
    NSLog(@"All contents: %@", [self getOrderItems]);

}

- (void)removeItemFromOrder:(IODItem*)inItem {
    IODItem* key = [self findKeyForOrderItem:inItem];
    
    if (key) {
        NSNumber* quantity = [[self getOrderItems] objectForKey:key];
        int intQuantity = [quantity intValue];
        intQuantity--;
        
       // [[self getOrderItems] removeObjectForKey:key];
        
        if (intQuantity > 0)
            [[self getOrderItems] setObject:[NSNumber numberWithInt:intQuantity] forKey:key];
        else
            [[self getOrderItems] removeObjectForKey:key];
    }
    NSLog(@"All contents: %@", [self getOrderItems]);
}

- (float)totalOrder {
    __block float total = 0.0;
    float (^itemTotal)(float,int) = ^float(float price, int quantity) {
        return price * quantity;
    };
    
    [[self getOrderItems] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        IODItem* item = (IODItem*)key;
        NSNumber* quantity = (NSNumber*)obj;
        int intQuantity = [quantity intValue];
        
        total += itemTotal([item price],intQuantity);
    }];
    
    return total;
}

@end
