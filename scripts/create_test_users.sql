-- Inserir alguns usuários de teste para facilitar os testes
-- Estes usuários terão a senha padrão: estudante123

-- Estudantes de teste
INSERT INTO auth.users (
  id,
  email,
  encrypted_password,
  email_confirmed_at,
  created_at,
  updated_at,
  raw_user_meta_data
) VALUES 
(
  gen_random_uuid(),
  'joao@estudante.app',
  crypt('estudante123', gen_salt('bf')),
  NOW(),
  NOW(),
  NOW(),
  '{"name": "João Silva", "role": "student", "matricula": "2024001"}'::jsonb
),
(
  gen_random_uuid(),
  'maria@estudante.app', 
  crypt('estudante123', gen_salt('bf')),
  NOW(),
  NOW(),
  NOW(),
  '{"name": "Maria Santos", "role": "student", "matricula": "2024002"}'::jsonb
),
(
  gen_random_uuid(),
  'organizador@escola.com',
  crypt('estudante123', gen_salt('bf')),
  NOW(),
  NOW(),
  NOW(),
  '{"name": "Coordenador", "role": "organizer"}'::jsonb
);

-- Confirmar emails automaticamente
UPDATE auth.users SET email_confirmed_at = NOW() WHERE email_confirmed_at IS NULL;
