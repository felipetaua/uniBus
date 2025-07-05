-- Criar tabela de presenças
CREATE TABLE IF NOT EXISTS attendances (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  date DATE NOT NULL,
  will_attend BOOLEAN NOT NULL,
  student_name TEXT,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, date)
);

-- Habilitar RLS (Row Level Security)
ALTER TABLE attendances ENABLE ROW LEVEL SECURITY;

-- Política para estudantes verem apenas seus próprios registros
CREATE POLICY "Users can view own attendances" ON attendances
  FOR SELECT USING (auth.uid() = user_id);

-- Política para estudantes criarem/atualizarem seus próprios registros
CREATE POLICY "Users can insert own attendances" ON attendances
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own attendances" ON attendances
  FOR UPDATE USING (auth.uid() = user_id);

-- Política para organizadores verem todos os registros
CREATE POLICY "Organizers can view all attendances" ON attendances
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM auth.users 
      WHERE auth.users.id = auth.uid() 
      AND auth.users.raw_user_meta_data->>'role' = 'organizer'
    )
  );

-- Índices para performance
CREATE INDEX IF NOT EXISTS idx_attendances_user_date ON attendances(user_id, date);
CREATE INDEX IF NOT EXISTS idx_attendances_date ON attendances(date);

-- Função para atualizar updated_at automaticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger para atualizar updated_at
CREATE TRIGGER update_attendances_updated_at 
  BEFORE UPDATE ON attendances 
  FOR EACH ROW 
  EXECUTE FUNCTION update_updated_at_column();
