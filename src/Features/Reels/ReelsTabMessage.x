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

// Intercept tap on the Reels tab button and show a random deterrent message
%hook IGTabBarButton

- (void)didMoveToSuperview {
    %orig;

    if (![self.accessibilityIdentifier isEqualToString:@"clips-tab"]) return;

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleReelsTap:)];
    tap.cancelsTouchesInView = YES;

    // Priorité sur les gesture recognizers existants d'Instagram
    for (UIGestureRecognizer *existing in self.gestureRecognizers) {
        [existing requireGestureRecognizerToFail:tap];
    }

    [self addGestureRecognizer:tap];
}

%new - (void)handleReelsTap:(UITapGestureRecognizer *)sender {
    if (sender.state != UIGestureRecognizerStateRecognized) return;

    UIAlertController *alert = [UIAlertController
        alertControllerWithTitle:@"Accès bloqué"
        message:randomReelsMessage()
        preferredStyle:UIAlertControllerStyleAlert];

    [alert addAction:[UIAlertAction
        actionWithTitle:@"OK"
        style:UIAlertActionStyleDefault
        handler:nil]];

    [topMostController() presentViewController:alert animated:YES completion:nil];
}

%end
