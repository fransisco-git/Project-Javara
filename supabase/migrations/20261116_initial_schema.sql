-- =============================================================================
-- JAVARA: AI-POWERED CULTURAL FASHION PLATFORM
-- INITIAL DATABASE SCHEMA & POSTGRESQL ARCHITECTURE
-- Migration: 20261116_initial_schema.sql
-- =============================================================================

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- -----------------------------------------------------------------------------
-- 1. PROFILES (Extends Supabase auth.users)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    username TEXT UNIQUE,
    full_name TEXT,
    avatar_url TEXT,
    preferred_region TEXT DEFAULT 'Surakarta Hadiningrat',
    gender_preference TEXT DEFAULT 'all' CHECK (gender_preference IN ('all', 'pria', 'wanita')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- -----------------------------------------------------------------------------
-- 2. CULTURAL REGIONS (Wilayah Budaya Tradisi Jawa Tengah)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.cultural_regions (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    sub_regions TEXT NOT NULL,
    javanese_script TEXT NOT NULL,
    description TEXT NOT NULL,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- -----------------------------------------------------------------------------
-- 3. CULTURAL SOURCES (Sumber Rujukan Literatur & Manuskrip Sejarah)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.cultural_sources (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    author TEXT,
    period TEXT,
    institution TEXT,
    description TEXT,
    citation TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- -----------------------------------------------------------------------------
-- 4. CLOTHING CATEGORIES (Kategori Anatomi Busana Adat)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.clothing_categories (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    javanese_name TEXT NOT NULL,
    description TEXT,
    layer_order INTEGER NOT NULL DEFAULT 1
);

-- -----------------------------------------------------------------------------
-- 5. CLOTHING ITEMS (Entitas Busana Adat Jawa Tengah)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.clothing_items (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    javanese_script TEXT NOT NULL,
    category_id TEXT NOT NULL REFERENCES public.clothing_categories(id) ON DELETE RESTRICT,
    gender TEXT NOT NULL CHECK (gender IN ('pria', 'wanita', 'unisex')),
    region_id TEXT NOT NULL REFERENCES public.cultural_regions(id) ON DELETE RESTRICT,
    period TEXT NOT NULL,
    social_context TEXT NOT NULL,
    material TEXT NOT NULL,
    philosophical_meaning TEXT NOT NULL,
    cutting_and_construction TEXT NOT NULL,
    texture_motif TEXT NOT NULL,
    compatibility_keys TEXT[] NOT NULL DEFAULT '{}',
    color_palette TEXT[] NOT NULL DEFAULT '{}',
    historical_notes TEXT,
    references TEXT,
    asset_image_path TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- -----------------------------------------------------------------------------
-- 6. CLOTHING COMPONENTS (Detail Ricikan & Aksesoris Busana)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.clothing_components (
    id TEXT PRIMARY KEY,
    clothing_item_id TEXT REFERENCES public.clothing_items(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    javanese_script TEXT,
    component_type TEXT NOT NULL, -- kancing, kerah, wiron, sabuk, pendok, dll.
    material TEXT NOT NULL,
    placement_rule TEXT NOT NULL,
    philosophy TEXT
);

-- -----------------------------------------------------------------------------
-- 7. AVATARS (Model Manusia Realistis & Karakter 3D PBR)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.avatars (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    subtitle TEXT NOT NULL,
    gender TEXT NOT NULL CHECK (gender IN ('pria', 'wanita')),
    region_id TEXT REFERENCES public.cultural_regions(id) ON DELETE SET NULL,
    image_asset TEXT NOT NULL,
    mesh_glb_path TEXT,
    tags TEXT[] NOT NULL DEFAULT '{}',
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- -----------------------------------------------------------------------------
-- 8. OUTFIT PRESETS (Kurasi Setelan Busana Lengkap)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.outfit_presets (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    javanese_script TEXT NOT NULL,
    collection_category TEXT NOT NULL,
    gender TEXT NOT NULL CHECK (gender IN ('pria', 'wanita', 'unisex')),
    region_id TEXT NOT NULL REFERENCES public.cultural_regions(id) ON DELETE RESTRICT,
    era TEXT NOT NULL,
    headwear_id TEXT REFERENCES public.clothing_items(id) ON DELETE SET NULL,
    upper_body_id TEXT REFERENCES public.clothing_items(id) ON DELETE SET NULL,
    lower_body_id TEXT REFERENCES public.clothing_items(id) ON DELETE SET NULL,
    accessory_ids TEXT[] NOT NULL DEFAULT '{}',
    summary TEXT NOT NULL,
    cultural_philosophy TEXT NOT NULL,
    etiquette_rules TEXT NOT NULL,
    historical_sources TEXT NOT NULL,
    dominant_colors TEXT[] NOT NULL DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- -----------------------------------------------------------------------------
-- 9. AI GENERATIONS (Riwayat Virtual Try-On FASHN AI)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.ai_generations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    fashn_prediction_id TEXT,
    model_id TEXT REFERENCES public.avatars(id) ON DELETE SET NULL,
    garment_id TEXT REFERENCES public.clothing_items(id) ON DELETE SET NULL,
    outfit_preset_id TEXT REFERENCES public.outfit_presets(id) ON DELETE SET NULL,
    input_model_url TEXT NOT NULL,
    input_garment_url TEXT NOT NULL,
    output_image_url TEXT,
    status TEXT NOT NULL DEFAULT 'completed' CHECK (status IN ('starting', 'in_progress', 'completed', 'failed')),
    generation_time_ms INTEGER DEFAULT 0,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- -----------------------------------------------------------------------------
-- 10. SAVED OUTFITS (Koleksi Busana Tersimpan Pengguna)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.saved_outfits (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    custom_name TEXT NOT NULL,
    gender TEXT NOT NULL CHECK (gender IN ('pria', 'wanita')),
    headwear_id TEXT REFERENCES public.clothing_items(id) ON DELETE SET NULL,
    upper_body_id TEXT REFERENCES public.clothing_items(id) ON DELETE SET NULL,
    lower_body_id TEXT REFERENCES public.clothing_items(id) ON DELETE SET NULL,
    accessory_ids TEXT[] NOT NULL DEFAULT '{}',
    is_historically_verified BOOLEAN NOT NULL DEFAULT true,
    harmony_rating DOUBLE PRECISION NOT NULL DEFAULT 1.0,
    notes TEXT DEFAULT '',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- -----------------------------------------------------------------------------
-- 11. FAVORITES (Bookmark Item Budaya Pengguna)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.favorites (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    item_type TEXT NOT NULL CHECK (item_type IN ('outfit', 'garment', 'motif', 'story')),
    item_id TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, item_type, item_id)
);

-- =============================================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- =============================================================================
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cultural_regions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cultural_sources ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.clothing_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.clothing_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.clothing_components ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.avatars ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.outfit_presets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ai_generations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.saved_outfits ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.favorites ENABLE ROW LEVEL SECURITY;

-- 1. Public Read Policies for Curated Heritage Content
CREATE POLICY "Public read for cultural_regions" ON public.cultural_regions FOR SELECT USING (true);
CREATE POLICY "Public read for cultural_sources" ON public.cultural_sources FOR SELECT USING (true);
CREATE POLICY "Public read for clothing_categories" ON public.clothing_categories FOR SELECT USING (true);
CREATE POLICY "Public read for clothing_items" ON public.clothing_items FOR SELECT USING (true);
CREATE POLICY "Public read for clothing_components" ON public.clothing_components FOR SELECT USING (true);
CREATE POLICY "Public read for avatars" ON public.avatars FOR SELECT USING (true);
CREATE POLICY "Public read for outfit_presets" ON public.outfit_presets FOR SELECT USING (true);

-- 2. User-specific Private Policies (Profiles, Generations, Saved Outfits, Favorites)
CREATE POLICY "Users can view own profile" ON public.profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON public.profiles FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can view own generations" ON public.ai_generations FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own generations" ON public.ai_generations FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view own saved outfits" ON public.saved_outfits FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own saved outfits" ON public.saved_outfits FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own saved outfits" ON public.saved_outfits FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own saved outfits" ON public.saved_outfits FOR DELETE USING (auth.uid() = user_id);

CREATE POLICY "Users can view own favorites" ON public.favorites FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own favorites" ON public.favorites FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can delete own favorites" ON public.favorites FOR DELETE USING (auth.uid() = user_id);

