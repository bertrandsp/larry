import { createClient, SupabaseClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';

dotenv.config();

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseServiceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

let supabase: SupabaseClient | null = null;

if (!supabaseUrl || !supabaseServiceRoleKey || 
    supabaseUrl === 'your_supabase_url_here' || 
    supabaseServiceRoleKey === 'your_supabase_service_role_key_here') {
  console.warn('⚠️  Supabase credentials not configured. Using mock mode.');
  console.warn('   To use real Supabase, set SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY in .env');
  supabase = null;
} else {
  supabase = createClient(supabaseUrl, supabaseServiceRoleKey, {
    auth: {
      persistSession: false, // Backend typically doesn't need to persist sessions
      autoRefreshToken: false,
      detectSessionInUrl: false,
    },
  });
  
  console.log('✅ Supabase client initialized for backend.');
}

export { supabase };
