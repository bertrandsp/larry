import { supabase, supabaseAdmin } from '../config/supabase';

// Export Supabase clients for use throughout the app
export const db = supabase;
export const dbAdmin = supabaseAdmin;

// Database service functions using Supabase directly
export const database = {
  // Topic operations
  topics: {
    async getAll() {
      const { data, error } = await db.from('topics').select('*');
      if (error) throw error;
      return data;
    },
    
    async getById(id: string) {
      const { data, error } = await db.from('topics').select('*').eq('id', id).single();
      if (error) throw error;
      return data;
    },
    
    async create(topicData: any) {
      const { data, error } = await db.from('topics').insert(topicData).select().single();
      if (error) throw error;
      return data;
    },
    
    async update(id: string, updateData: any) {
      const { data, error } = await db.from('topics').update(updateData).eq('id', id).select().single();
      if (error) throw error;
      return data;
    },
    
    async delete(id: string) {
      const { error } = await db.from('topics').delete().eq('id', id);
      if (error) throw error;
    }
  },
  
  // Term operations
  terms: {
    async getAll(filters?: any) {
      let query = db.from('terms').select('*');
      
      if (filters?.topicId) {
        query = query.eq('topic_id', filters.topicId);
      }
      
      if (filters?.ids && Array.isArray(filters.ids)) {
        query = query.in('id', filters.ids);
      }
      
      const { data, error } = await query;
      if (error) throw error;
      return data;
    },
    
    async getById(id: string) {
      const { data, error } = await db.from('terms').select('*').eq('id', id).single();
      if (error) throw error;
      return data;
    },
    
    async create(termData: any) {
      const { data, error } = await db.from('terms').insert(termData).select().single();
      if (error) throw error;
      return data;
    },
    
    async update(id: string, updateData: any) {
      const { data, error } = await db.from('terms').update(updateData).eq('id', id).select().single();
      if (error) throw error;
      return data;
    },
    
    async delete(id: string) {
      const { error } = await db.from('terms').delete().eq('id', id);
      if (error) throw error;
    }
  },
  
  // User operations
  users: {
    async getAll() {
      const { data, error } = await db.from('users').select('*');
      if (error) throw error;
      return data;
    },
    
    async getById(id: string) {
      const { data, error } = await db.from('users').select('*').eq('id', id).single();
      if (error) throw error;
      return data;
    },
    
    async create(userData: any) {
      const { data, error } = await db.from('users').insert(userData).select().single();
      if (error) throw error;
      return data;
    },
    
    async update(id: string, updateData: any) {
      const { data, error } = await db.from('users').update(updateData).eq('id', id).select().single();
      if (error) throw error;
      return data;
    },
    
    async delete(id: string) {
      const { error } = await db.from('users').delete().eq('id', id);
      if (error) throw error;
    }
  },
  
  // Fact operations
  facts: {
    async getAll(filters?: any) {
      let query = db.from('facts').select('*');
      
      if (filters?.topicId) {
        query = query.eq('topic_id', filters.topicId);
      }
      
      const { data, error } = await query;
      if (error) throw error;
      return data;
    },
    
    async getById(id: string) {
      const { data, error } = await db.from('facts').select('*').eq('id', id).single();
      if (error) throw error;
      return data;
    },
    
    async create(factData: any) {
      const { data, error } = await db.from('facts').insert(factData).select().single();
      if (error) throw error;
      return data;
    },
    
    async update(id: string, updateData: any) {
      const { data, error } = await db.from('facts').update(updateData).eq('id', id).select().single();
      if (error) throw error;
      return data;
    },
    
    async delete(id: string) {
      const { error } = await db.from('facts').delete().eq('id', id);
      if (error) throw error;
    }
  },
  
  // Metric Log operations
  metrics: {
    async getAll(filters?: any) {
      let query = db.from('metric_logs').select('*');
      
      if (filters?.type) {
        query = query.eq('type', filters.type);
      }
      
      if (filters?.topicId) {
        query = query.eq('topic_id', filters.topicId);
      }
      
      if (filters?.createdAt && filters.createdAt.gte) {
        query = query.gte('created_at', filters.createdAt.gte);
      }
      
      const { data, error } = await query;
      if (error) throw error;
      return data;
    },
    
    async create(metricData: any) {
      const { data, error } = await db.from('metric_logs').insert(metricData).select().single();
      if (error) throw error;
      return data;
    },
    
    async getGroupedMetrics(filters: any) {
      // Get all matching records
      let query = db.from('metric_logs').select('*');
      
      if (filters.type) {
        query = query.eq('type', filters.type);
      }
      
      if (filters.createdAt && filters.createdAt.gte) {
        query = query.gte('created_at', filters.createdAt.gte);
      }
      
      if (filters.limit) {
        query = query.limit(filters.limit);
      }
      
      const { data, error } = await query;
      if (error) throw error;
      
      // Group manually
      const grouped: any = {};
      (data || []).forEach((item: any) => {
        const key = item.metadata ? JSON.stringify(item.metadata) : 'default';
        if (!grouped[key]) {
          grouped[key] = { ...item, _count: 0 };
        }
        grouped[key]._count++;
      });
      
      return Object.values(grouped);
    }
  }
};

// For backward compatibility, export as 'prisma' but mark as deprecated
export const prisma = {
  topic: database.topics,
  term: database.terms,
  user: database.users,
  fact: database.facts,
  metricLog: database.metrics,
  jobMetric: database.metrics, // Alias
  userProgress: database.users // Alias
};


