# Boas práticas e segurança

## Mensagens de commit

Resumo curto no imperativo (~50 caracteres), linha em branco, corpo
explicando o *porquê* se necessário:

```
tipo: resumo curto no imperativo

Corpo opcional explicando o porquê da mudança (o "o quê" já está no diff).
```

### Conventional Commits (padrão para os commits automáticos desta skill)

```
feat(auth): adiciona login via Google
fix(checkout): corrige cálculo de frete grátis
chore: atualiza dependências
refactor(api): extrai validação para middleware
docs: atualiza README com instruções de setup
```

Tipos comuns: `feat`, `fix`, `chore`, `refactor`, `docs`, `test`, `style`,
`perf`, `ci`, `build`.

## Commits pequenos e atômicos

Cada commit = uma mudança lógica coesa. Facilita `revert`, `bisect`, code
review e histórico legível. Evitar commits que deixam o build quebrado no
meio do histórico.

## Nunca commitar segredos

Chaves de API, senhas, tokens, `.env`, certificados privados:

- `.gitignore` desde o início do projeto: `.env`, `.env.*`, `*.pem`,
  `*.key`, pastas de credenciais.
- Preferir variáveis de ambiente / gerenciador de segredos a arquivos
  versionados.
- **Se vazar**: apagar num commit novo NÃO resolve — o segredo continua no
  histórico.
  1. **Trocar a credencial imediatamente** (o passo mais importante).
  2. Limpar do histórico com `git filter-repo` (ver
     [comandos avançados](comandos-avancados.md)).
  3. `push --force` da branch reescrita — **sempre com autorização
     explícita do usuário**, e avisar sobre re-clone necessário.

## `push --force` — sempre com cautela e autorização

`push --force` sobrescreve histórico remoto e pode apagar trabalho alheio
silenciosamente. Quando o usuário autorizar um force push, preferir:

```bash
git push --force-with-lease
```

que recusa a operação se detectar que alguém mais empurrou mudanças desde
a última sincronização.

## `.gitignore` desde o início

Cobrir artefatos de build (`node_modules`, `dist`, `venv`), arquivos de
IDE/SO (`.vscode/`, `.DS_Store`) e segredos. Templates prontos por
linguagem: https://github.com/github/gitignore.

## Outras práticas

- Revisar o próprio diff antes de commitar (`git diff --staged`) — pega
  arquivos esquecidos, `console.log`/`print` de debug.
- Branches de vida curta — quanto mais tempo isolada, maior o risco de
  conflito grande na hora de integrar.
- Nunca `git push`, `git pull`, `git fetch`, criação de repositório remoto,
  ou qualquer ação que afete o GitHub/GitLab sem autorização explícita do
  usuário **naquele momento da conversa** — commits e branches locais não
  precisam dessa autorização.
