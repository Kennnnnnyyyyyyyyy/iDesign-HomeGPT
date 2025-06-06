import { beforeUserCreated, beforeUserSignedIn } from 'firebase-functions/v2/identity';
import { setGlobalOptions } from 'firebase-functions/v2';

// ✅ Optional: Set default region and options
setGlobalOptions({ region: 'us-central1' });

/**
 * ✅ Runs BEFORE a user account is created.
 * Adds a custom claim `role: 'authenticated'`.
 */
export const beforecreated = beforeUserCreated(() => {
  return {
    customClaims: {
      role: 'authenticated',
    },
  };
});

/**
 * ✅ Runs BEFORE an existing user signs in.
 * Ensures the user has `role: 'authenticated'` in every ID token.
 */
export const beforesignedin = beforeUserSignedIn(() => {
  return {
    customClaims: {
      role: 'authenticated',
    },
  };
});
