In Objective-C, a subtle issue can arise when dealing with KVO (Key-Value Observing) and memory management. If an observer is not removed properly before the observed object is deallocated, it can lead to crashes or unexpected behavior.  This often happens when the observer is a strong reference to the observed object, creating a retain cycle. Even if the observer is weak, if the observed object is deallocated before the observer is removed, a dangling pointer will remain, leading to a potential crash.

For example:

```objectivec
@interface MyObserver : NSObject
@property (nonatomic, weak) MyObservedObject *observedObject;
@end

@implementation MyObserver
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    // ... handle changes ...
}
@end

@interface MyObservedObject : NSObject
@end

@implementation MyObservedObject
- (void)dealloc {
    NSLog(@"MyObservedObject deallocated");
}
@end

// ... later in some code ...
MyObservedObject *observed = [[MyObservedObject alloc] init];
MyObserver *observer = [[MyObserver alloc] init];
observer.observedObject = observed;
[observed addObserver:observer forKeyPath:@"someProperty" options:NSKeyValueObservingOptionNew context:NULL];
// ... some operations ...
// Failure to remove the observer before observed is deallocated leads to problems
[observed removeObserver:observer forKeyPath:@"someProperty"]; //MUST do this before releasing observed
[observed release]; //If observer isn't removed, it can cause problems
[observer release];
```