<<<<<<< HEAD
import { createClient } from '@supabase/supabase-js';
const url = import.meta.env.VITE_SUPABASE_URL as string | undefined;
const key = import.meta.env.VITE_SUPABASE_ANON_KEY as string | undefined;
export const isSupabaseConfigured = Boolean(url && key && url.startsWith('https://'));
export const supabase = createClient(url || 'https://placeholder.supabase.co', key || 'placeholder-anon-key');
=======
import { createClient } from '@supabase/supabase-js';
const url = import.meta.env.VITE_SUPABASE_URL as string | undefined;
const key = import.meta.env.VITE_SUPABASE_ANON_KEY as string | undefined;
export const isSupabaseConfigured = Boolean(url && key && url.startsWith('https://'));
export const supabase = createClient(url || 'https://placeholder.supabase.co', key || 'placeholder-anon-key');
>>>>>>> cb811b9add1323c52fbe743c4b346b08e7c7b466
