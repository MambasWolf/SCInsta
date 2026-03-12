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

    // LOG 1 — Le hook est bien actif, on voit tous les boutons de la tab bar
    NSLog(@"[SCInsta-DEBUG] IGTabBarButton didMoveToSuperview — accessibilityIdentifier: '%@' | class: %@",
          self.accessibilityIdentifier, NSStringFromClass([self class]));

    if (![self.accessibilityIdentifier isEqualToString:@"clips-tab"]) return;

    // LOG 2 — On a trouvé le bon bouton
    NSLog(@"[SCInsta-DEBUG] ✅ Bouton Reels trouvé ! Ajout du gesture recognizer.");

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleReelsTap:)];
    tap.cancelsTouchesInView = YES;

    // Priorité sur les gesture recognizers existants d'Instagram
    for (UIGestureRecognizer *existing in self.gestureRecognizers) {
        [existing requireGestureRecognizerToFail:tap];
    }

    [self addGestureRecognizer:tap];
}

- (void)didMoveToWindow {
    %orig;

    // LOG 3 — Vérification plus tardive (après didMoveToSuperview)
    if (self.accessibilityIdentifier.length > 0) {
        NSLog(@"[SCInsta-DEBUG] IGTabBarButton didMoveToWindow — accessibilityIdentifier: '%@'",
              self.accessibilityIdentifier);
    }

    // Si le gesture recognizer n'a pas été ajouté dans didMoveToSuperview
    // (parce que l'identifier n'était pas encore set), on réessaie ici
    if (![self.accessibilityIdentifier isEqualToString:@"clips-tab"]) return;

    // Évite d'ajouter plusieurs fois le même gesture recognizer
    for (UIGestureRecognizer *gr in self.gestureRecognizers) {
        if ([gr isKindOfClass:[UITapGestureRecognizer class]] &&
            [gr.description containsString:@"handleReelsTap"]) {
            NSLog(@"[SCInsta-DEBUG] GR déjà ajouté, on skip didMoveToWindow.");
            return;
        }
    }

    NSLog(@"[SCInsta-DEBUG] ✅ Ajout du GR depuis didMoveToWindow (identifier arrivé tard).");
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleReelsTap:)];
    tap.cancelsTouchesInView = YES;
    for (UIGestureRecognizer *existing in self.gestureRecognizers) {
        [existing requireGestureRecognizerToFail:tap];
    }
    [self addGestureRecognizer:tap];
}

%new - (void)handleReelsTap:(UITapGestureRecognizer *)sender {
    // LOG 4 — Le tap est-il détecté ?
    NSLog(@"[SCInsta-DEBUG] 👆 handleReelsTap appelé — state: %ld", (long)sender.state);

    if (sender.state != UIGestureRecognizerStateRecognized) return;

    NSLog(@"[SCInsta-DEBUG] 💬 Affichage de l'alerte...");

    UIViewController *topVC = topMostController();
    NSLog(@"[SCInsta-DEBUG] topMostController: %@", topVC);

    UIAlertController *alert = [UIAlertController
        alertControllerWithTitle:@"Accès bloqué"
        message:randomReelsMessage()
        preferredStyle:UIAlertControllerStyleAlert];

    [alert addAction:[UIAlertAction
        actionWithTitle:@"OK"
        style:UIAlertActionStyleDefault
        handler:nil]];

    [topVC presentViewController:alert animated:YES completion:nil];
}

%end
