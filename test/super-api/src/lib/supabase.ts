import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';

// Load environment variables
dotenv.config();

const supabaseUrl = process.env.SUPABASE_URL || 'https://greuppfemzgunszxpveq.supabase.co';
const supabaseAnonKey = process.env.SUPABASE_ANON_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdyZXVwcGZlbXpndW5zenhwdmVxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTg1MDQ4NjIsImV4cCI6MjA3NDA4MDg2Mn0.mXokGtoUjil1xI8AjVevF41_ofmWZVq2rEjYW5iWfS0';

console.log('🔌 Connecting to Supabase:', supabaseUrl);

export const supabase = createClient(supabaseUrl, supabaseAnonKey);

// Database helper functions
export const db = {
  // Users
  async createUser(userData: any) {
    const { data, error } = await supabase
      .from('users')
      .insert(userData)
      .select()
      .single();
    if (error) throw error;
    return data;
  },

  async getUser(userId: string) {
    const { data, error } = await supabase
      .from('users')
      .select('*')
      .eq('id', userId)
      .single();
    if (error) throw error;
    return data;
  },

  async updateUser(userId: string, updates: any) {
    const { data, error } = await supabase
      .from('users')
      .update(updates)
      .eq('id', userId)
      .select()
      .single();
    if (error) throw error;
    return data;
  },

  // Topics
  async getAllTopics() {
    const { data, error } = await supabase
      .from('topics')
      .select('*')
      .order('name');
    if (error) throw error;
    return data;
  },

  async getTopic(topicId: string) {
    const { data, error } = await supabase
      .from('topics')
      .select('*')
      .eq('id', topicId)
      .single();
    if (error) throw error;
    return data;
  },

  // User Topics
  async getUserTopics(userId: string) {
    const { data, error } = await supabase
      .from('user_topics')
      .select('*, topics(*)')
      .eq('user_id', userId);
    if (error) throw error;
    return data;
  },

  async createUserTopic(userId: string, topicId: string, weight: number = 10) {
    const { data, error } = await supabase
      .from('user_topics')
      .insert({
        user_id: userId,
        topic_id: topicId,
        weight: weight
      })
      .select()
      .single();
    if (error) throw error;
    return data;
  },

  // Terms
  async createTerm(termData: any) {
    const { data, error } = await supabase
      .from('terms')
      .insert(termData)
      .select()
      .single();
    if (error) throw error;
    return data;
  },

  async getTerm(termId: string) {
    const { data, error } = await supabase
      .from('terms')
      .select('*')
      .eq('id', termId)
      .single();
    if (error) throw error;
    return data;
  },

  // Deliveries
  async createDelivery(deliveryData: any) {
    const { data, error } = await supabase
      .from('deliveries')
      .insert(deliveryData)
      .select()
      .single();
    if (error) throw error;
    return data;
  },

  async updateDelivery(deliveryId: string, updates: any) {
    const { data, error } = await supabase
      .from('deliveries')
      .update(updates)
      .eq('id', deliveryId)
      .select()
      .single();
    if (error) throw error;
    return data;
  },

  async getUserDeliveries(userId: string) {
    const { data, error } = await supabase
      .from('deliveries')
      .select('*, terms(*)')
      .eq('user_id', userId)
      .order('created_at', { ascending: false });
    if (error) throw error;
    return data;
  },

  // Wordbank
  async createWordbankEntry(wordbankData: any) {
    const { data, error } = await supabase
      .from('wordbank')
      .insert(wordbankData)
      .select()
      .single();
    if (error) throw error;
    return data;
  },

  async updateWordbankEntry(userId: string, termId: string, updates: any) {
    const { data, error } = await supabase
      .from('wordbank')
      .update(updates)
      .eq('user_id', userId)
      .eq('term_id', termId)
      .select()
      .single();
    if (error) throw error;
    return data;
  },

  async getUserWordbank(userId: string) {
    const { data, error } = await supabase
      .from('wordbank')
      .select('*, terms(*)')
      .eq('user_id', userId)
      .order('last_reviewed', { ascending: true });
    if (error) throw error;
    return data;
  },

  // Get words for spaced repetition
  async getWordsForReview(userId: string, limit: number = 10) {
    const { data, error } = await supabase
      .from('wordbank')
      .select('*, terms(*)')
      .eq('user_id', userId)
      .in('status', ['learning', 'reviewing'])
      .lte('next_review', new Date().toISOString())
      .order('next_review', { ascending: true })
      .limit(limit);
    if (error) throw error;
    return data;
  }
};

export default supabase;
