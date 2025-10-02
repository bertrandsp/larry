import { supabase } from '../config/supabase';
import { hashPassword, verifyPassword } from './auth';

/**
 * Database-based authentication utilities
 * Uses the password field in the User table
 */

export class DatabaseAuth {
  /**
   * Set a user's password in the database
   */
  static async setUserPassword(email: string, password: string): Promise<boolean> {
    if (!supabase) {
      console.error('❌ Supabase not available for password storage');
      return false;
    }

    try {
      const hashedPassword = await hashPassword(password);
      
      const { error } = await supabase
        .from('User')
        .update({ password: hashedPassword })
        .eq('email', email);

      if (error) {
        console.error('❌ Error setting password:', error);
        return false;
      }

      console.log(`✅ Password set for user: ${email}`);
      return true;
    } catch (error) {
      console.error('❌ Error in setUserPassword:', error);
      return false;
    }
  }

  /**
   * Verify a user's password from the database
   */
  static async verifyUserPassword(email: string, password: string): Promise<boolean> {
    if (!supabase) {
      console.error('❌ Supabase not available for password verification');
      return false;
    }

    try {
      const { data: user, error } = await supabase
        .from('User')
        .select('password')
        .eq('email', email)
        .single();

      if (error || !user) {
        console.log(`❌ User not found: ${email}`);
        return false;
      }

      if (!user.password) {
        console.log(`❌ No password set for user: ${email}`);
        return false;
      }

      const isValid = await verifyPassword(password, user.password);
      console.log(`🔐 Password verification for ${email}: ${isValid ? 'SUCCESS' : 'FAILED'}`);
      return isValid;
    } catch (error) {
      console.error('❌ Error in verifyUserPassword:', error);
      return false;
    }
  }

  /**
   * Check if a user has a password set
   */
  static async hasPassword(email: string): Promise<boolean> {
    if (!supabase) {
      return false;
    }

    try {
      const { data: user, error } = await supabase
        .from('User')
        .select('password')
        .eq('email', email)
        .single();

      return !error && user && !!user.password;
    } catch (error) {
      console.error('❌ Error checking password existence:', error);
      return false;
    }
  }

  /**
   * Migrate a user from temporary password store to database
   */
  static async migrateFromTempStore(email: string, tempPassword: string): Promise<boolean> {
    try {
      // Check if user already has password in database
      const hasDbPassword = await this.hasPassword(email);
      if (hasDbPassword) {
        console.log(`✅ User ${email} already has database password`);
        return true;
      }

      // Set password in database
      const success = await this.setUserPassword(email, tempPassword);
      if (success) {
        console.log(`✅ Migrated password for ${email} from temp store to database`);
      }
      return success;
    } catch (error) {
      console.error('❌ Error migrating password:', error);
      return false;
    }
  }
}
