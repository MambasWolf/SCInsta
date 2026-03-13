#import "../../Utils.h"
#import "../../InstagramHeaders.h"

static NSString *randomReelsMessage() {
    NSArray *messages = @[
        @"Crotte de pigeon. Vas pas ici.",
        @"Tu vaux mieux que ça.",
        @"Je veux pas être boomer. Mais va toucher de l'herbe.",
        @"Va manger des haricots verts.",
        @"Vas boire de l'eau au moins.",
        @"Tu as installé un truc pour pas faire ça. Et tu le fais quand même.",
        @"Tu as déverrouillé ton téléphone 23 fois aujourd'hui. Cherche pas pourquoi.",
        @"Quelqu'un t'a mis ce message exprès. Tu vois qui c'est.",
        @"T'es chiante.",
        @"Cet algorithme te connaît mieux que ta mère.",
        @"Appuie sur retour. Ose.",
        @"Batterie cérébrale : 3%",
        @"Connexion à la réalité perdue depuis 47 minutes.",
        @"T'as vraiment rien de mieux à faire hein.",
        @"Ptn lâche ces reels. Arrête de Scroll.",
        @"Tu pourrais être en train de faire quelque chose de ta vie.",
    ];
    return messages[arc4random_uniform((uint32_t)messages.count)];
}

// Block the main Reels tab, but allow reels opened from DMs
%hook IGSundialFeedViewController

- (void)viewDidAppear:(BOOL)animated {
    %orig;

    // Walk up the parent VC chain to check if we're in the main Reels tab
    BOOL isMainReelsTab = NO;
    UIViewController *parent = self.parentViewController;
    while (parent) {
        if ([parent isKindOfClass:%c(IGTabBarController)]) {
            isMainReelsTab = YES;
            break;
        }
        parent = parent.parentViewController;
    }

    // Reel opened from DMs — allow normally
    if (!isMainReelsTab) {
        UIView *blocker = [self.view viewWithTag:31415];
        if (blocker) [blocker removeFromSuperview];
        return;
    }

    // Main Reels tab — block it
    if (self.presentedViewController) return;

    UIView *blocker = [self.view viewWithTag:31415];
    if (!blocker) {
        blocker = [[UIView alloc] initWithFrame:self.view.bounds];
        blocker.tag = 31415;
        blocker.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        blocker.backgroundColor = [UIColor blackColor];
        blocker.userInteractionEnabled = YES;
        [self.view addSubview:blocker];
    }
    [self.view bringSubviewToFront:blocker];

    UIAlertController *alert = [UIAlertController
        alertControllerWithTitle:@"Accès bloqué"
        message:randomReelsMessage()
        preferredStyle:UIAlertControllerStyleAlert];

    [alert addAction:[UIAlertAction
        actionWithTitle:@"OK"
        style:UIAlertActionStyleDefault
        handler:nil]];

    [self presentViewController:alert animated:YES completion:nil];
}

%end
