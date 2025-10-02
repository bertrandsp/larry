import { hashPassword, verifyPassword } from './auth';

// Temporary in-memory password store until database migration is complete
// In production, this should be stored in a secure database table
interface UserPassword {
  email: string;
  hashedPassword: string;
  createdAt: Date;
}

class PasswordStore {
  private passwords: Map<string, UserPassword> = new Map();

  async setPassword(email: string, password: string): Promise<void> {
    const hashedPassword = await hashPassword(password);
    this.passwords.set(email.toLowerCase(), {
      email: email.toLowerCase(),
      hashedPassword,
      createdAt: new Date()
    });
    console.log(`🔐 Password set for user: ${email}`);
  }

  async verifyPassword(email: string, password: string): Promise<boolean> {
    const userPassword = this.passwords.get(email.toLowerCase());
    if (!userPassword) {
      console.log(`🔐 No password found for user: ${email}`);
      return false;
    }

    const isValid = await verifyPassword(password, userPassword.hashedPassword);
    console.log(`🔐 Password verification for ${email}: ${isValid ? 'SUCCESS' : 'FAILED'}`);
    return isValid;
  }

  hasPassword(email: string): boolean {
    return this.passwords.has(email.toLowerCase());
  }

  // For development/testing - remove in production
  listUsers(): string[] {
    return Array.from(this.passwords.keys());
  }
}

// Singleton instance
export const passwordStore = new PasswordStore();

// No hardcoded credentials - all passwords should be stored in Supabase database
// This temporary store is only used as a fallback when database operations fail
