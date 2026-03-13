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

// Intercept the action dispatch of the Reels tab button before it fires
%hook IGTabBarButton

- (void)sendActionsForControlEvents:(UIControlEvents)controlEvents {
    // Only intercept actual tap events on the clips (Reels) tab
    if ((controlEvents & UIControlEventTouchUpInside) &&
        [self.accessibilityIdentifier isEqualToString:@"clips-tab"]) {

        UIViewController *topVC = topMostController();
        UIAlertController *alert = [UIAlertController
            alertControllerWithTitle:@"Accès bloqué"
            message:randomReelsMessage()
            preferredStyle:UIAlertControllerStyleAlert];

        [alert addAction:[UIAlertAction
            actionWithTitle:@"OK"
            style:UIAlertActionStyleDefault
            handler:nil]];

        [topVC presentViewController:alert animated:YES completion:nil];

        // Do NOT call %orig — this prevents the tab from actually switching
        return;
    }

    %orig;
}

%end
