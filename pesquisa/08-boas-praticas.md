# Boas práticas

## Commits pequenos e atômicos

Cada commit deve representar **uma mudança lógica coesa** — idealmente algo
que, sozinho, ainda deixa o projeto em estado consistente (compila, passa
os testes). Benefícios diretos:

- `git revert` de um commit específico não arrasta mudanças não
  relacionadas junto.
- `git bisect` consegue isolar exatamente qual mudança introduziu um bug.
- Code review fica mais fácil — revisar um commit pequeno e focado é muito
  mais rápido do que um commit gigante "fez tudo".
- `git blame`/histórico ficam mais informativos.

## Mensagens de commit descritivas

Convenção amplamente adotada (formato "imperativo", popularizado pelo
próprio guia de contribuição do kernel Linux e do Git):

```
Linha de resumo curta, no imperativo, até ~50 caracteres

Corpo explicando o *porquê* da mudança (não apenas o "o quê" — isso já
está no diff). Quebra de linha em ~72 caracteres. Pode ter múltiplos
parágrafos, listas, referências a issues.
```

- Resumo no imperativo: "Adiciona validação de e-mail" (não "Adicionado" /
  "Adicionando").
- Linha em branco obrigatória entre resumo e corpo (é o que faz
  ferramentas como `git log --oneline` e o GitHub tratarem a primeira
  linha como título).

### Conventional Commits

Padrão popular que estrutura o resumo como `tipo(escopo): descrição`:

```
feat(auth): adiciona login via Google
fix(checkout): corrige cálculo de frete grátis
chore: atualiza dependências
refactor(api): extrai validação para middleware
docs: atualiza README com instruções de setup
test: adiciona casos de borda para parser de datas
```

Tipos comuns: `feat`, `fix`, `chore`, `refactor`, `docs`, `test`, `style`,
`perf`, `ci`, `build`. Vantagem: permite gerar **changelogs
automaticamente** e até decidir versionamento semântico (semver)
automaticamente (`fix` → patch, `feat` → minor, `BREAKING CHANGE` → major),
via ferramentas como `semantic-release` ou `commitizen`.

## Nunca commitar segredos

Chaves de API, senhas, tokens, certificados privados, arquivos `.env`:

- Usar `.gitignore` **desde o início do projeto**, cobrindo padrões como
  `.env`, `.env.*`, `*.pem`, `*.key`, pastas de credenciais de nuvem, etc.
- Preferir variáveis de ambiente / gerenciadores de segredo (Vault, AWS
  Secrets Manager, GitHub Actions Secrets...) em vez de arquivos versionados.
- **Se um segredo vazar**: remover do commit mais recente **não resolve** —
  o segredo continua acessível no histórico. É preciso:
  1. **Revogar/trocar a credencial imediatamente** (o passo mais
     importante — o dado já pode ter sido copiado).
  2. Limpar do histórico com `git filter-repo` (ferramenta recomendada
     hoje pela documentação oficial) ou BFG Repo-Cleaner.
  3. Forçar push da branch reescrita e avisar colaboradores para
     re-clonarem (histórico reescrito é incompatível com clones antigos).
- Ferramentas de prevenção: `git-secrets`, `gitleaks`, hooks de
  `pre-commit` que bloqueiam padrões de segredo antes mesmo do commit
  local.

## Evitar `push --force` em branches compartilhadas

`push --force` sobrescreve o histórico remoto — se outra pessoa já puxou a
versão antiga e continuou trabalhando em cima dela, o force push pode
**apagar silenciosamente** o trabalho dela do remoto (ou gerar conflitos
dolorosos depois). Preferir:

```bash
git push --force-with-lease
```

que só força o push se ninguém mais empurrou mudanças para aquela branch
remota desde a última vez que você a sincronizou — recusa a operação
(protegendo o trabalho alheio) se detectar divergência inesperada.

Force push em branches puramente pessoais (ex.: sua própria branch de
feature, antes de abrir o PR) é normal e seguro.

## Pull Requests com revisão

Mesmo em projetos pequenos ou solo, abrir PR em vez de commitar direto em
`main` traz benefícios:

- Ponto de checagem antes de integrar (CI roda, testes automatizados
  validam).
- Histórico de discussão/decisões fica documentado, vinculado ao código.
- Facilita reverter uma feature inteira (revert do merge commit) se algo
  quebrar.

## `.gitignore` desde o início

Evita rastrear artefatos de build, dependências (`node_modules`, `venv`,
`vendor`), arquivos de IDE/SO (`.vscode/`, `.idea/`, `.DS_Store`) e
segredos. GitHub mantém uma coleção de templates prontos por linguagem/
framework: https://github.com/github/gitignore.

## Outras práticas úteis

- **Commitar código funcional**: evitar commits que deixam o build quebrado
  no meio do histórico (dificulta bisect e reverts).
- **Revisar o próprio diff antes de commitar** (`git diff --staged`) —
  pega arquivos esquecidos, `console.log`/`print` de debug, mudanças não
  intencionais.
- **Branches de vida curta**: quanto mais tempo uma branch de feature vive
  isolada, maior o risco de conflitos grandes na hora de integrar.
- **Assinar commits** (`git commit -S`, GPG/SSH) em projetos que exigem
  verificação de autoria — GitHub mostra um selo "Verified".
