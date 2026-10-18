-- Run this once in the Supabase SQL Editor for the project used by Wordwell.
create extension if not exists pgcrypto;

create table if not exists public.words (
  id uuid primary key default gen_random_uuid(),
  hanzi text not null check (length(trim(hanzi)) > 0),
  pinyin text not null check (length(trim(pinyin)) > 0),
  meaning text not null check (length(trim(meaning)) > 0),
  created_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now()
);

create index if not exists words_created_at_idx on public.words(created_at desc);
create unique index if not exists words_hanzi_unique_idx on public.words(hanzi);

create table if not exists public.picks (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  label text not null default 'Class practice',
  words jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default now()
);

create index if not exists picks_user_created_idx on public.picks(user_id, created_at desc);

alter table public.words enable row level security;
alter table public.picks enable row level security;

drop policy if exists "Anyone can read the shared word bank" on public.words;
create policy "Anyone can read the shared word bank" on public.words
  for select to anon, authenticated using (true);
drop policy if exists "Signed-in users can add shared words" on public.words;
create policy "Signed-in users can add shared words" on public.words
  for insert to authenticated with check (created_by = auth.uid());
drop policy if exists "Users can read their own picks" on public.picks;
create policy "Users can read their own picks" on public.picks
  for select to authenticated using (user_id = auth.uid());
drop policy if exists "Users can add their own picks" on public.picks;
create policy "Users can add their own picks" on public.picks
  for insert to authenticated with check (user_id = auth.uid());

grant usage on schema public to anon, authenticated;
grant select on public.words to anon, authenticated;
grant insert on public.words to authenticated;
grant select, insert on public.picks to authenticated;

-- Optional starter vocabulary. Remove these INSERTs if you want an empty bank.
insert into public.words(hanzi,pinyin,meaning) values
('你好','nǐ hǎo','hello; hi'),('谢谢','xièxie','thank you'),('再见','zàijiàn','goodbye'),
('朋友','péngyou','friend'),('老师','lǎoshī','teacher'),('学生','xuésheng','student'),
('今天','jīntiān','today'),('明天','míngtiān','tomorrow'),('喜欢','xǐhuan','to like'),
('学习','xuéxí','to study; to learn'),('吃饭','chīfàn','to eat; have a meal'),('喝水','hē shuǐ','to drink water'),
('好吃','hǎochī','delicious'),('漂亮','piàoliang','pretty; beautiful'),('忙','máng','busy'),
('高兴','gāoxìng','happy; glad'),('工作','gōngzuò','work; job'),('家','jiā','home; family'),
('书','shū','book'),('中国','Zhōngguó','China'),('中文','Zhōngwén','Chinese language'),
('哪里','nǎlǐ','where'),('为什么','wèishénme','why'),('因为','yīnwèi','because'),
('觉得','juéde','to feel; think'),('需要','xūyào','to need'),('一起','yìqǐ','together'),
('现在','xiànzài','now'),('可以','kěyǐ','can; may'),('但是','dànshì','but; however'),
('机场','jīchǎng','airport'),('咖啡','kāfēi','coffee'),('猫','māo','cat'),('狗','gǒu','dog'),
('天气','tiānqì','weather'),('热','rè','hot'),('冷','lěng','cold'),('慢慢','mànmàn','slowly'),
('开始','kāishǐ','to begin'),('结束','jiéshù','to finish'),('问题','wèntí','question; problem'),
('回答','huídá','to answer'),('打开','dǎkāi','to open; turn on'),('帮助','bāngzhù','to help'),
('如果','rúguǒ','if'),('可能','kěnéng','maybe; possible'),('知道','zhīdào','to know'),
('时间','shíjiān','time'),('周末','zhōumò','weekend')
on conflict (hanzi) do nothing;
