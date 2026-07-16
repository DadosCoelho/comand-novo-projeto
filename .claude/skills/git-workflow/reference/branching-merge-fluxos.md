# Branching, merge e fluxos de trabalho

## Fast-forward vs. merge commit

- **Fast-forward**: se a branch de destino não avançou desde que a branch
  atual foi criada, o Git só move o ponteiro — sem commit de merge.
- **Merge commit**: se as duas branches avançaram separadamente, o Git cria
  um commit com dois pais combinando as duas histórias.

```bash
git merge --no-ff <branch>   # força commit de merge mesmo quando fast-forward seria possível
```

## Merge vs. Rebase

| | Merge | Rebase |
|---|---|---|
| Histórico | Não-linear, preserva o que aconteceu | Linear, "limpo" |
| Hashes dos commits | Preservados | Mudam (commits novos) |
| Seguro em branch já publicada? | Sim, sempre | Só **antes** de publicar |
| Conflitos | Resolvidos uma vez | Podem repetir a cada commit reaplicado |

**Regra prática:** rebase é seguro em branches locais, ainda não enviadas
a um remote. Depois de publicada, prefira merge — reescrever histórico
compartilhado sem autorização quebra o trabalho de quem já baseou algo
nela.

## Resolvendo conflitos

```
<<<<<<< HEAD
versão da branch atual
=======
versão da branch sendo mesclada
>>>>>>> feature-branch
```

```bash
# editar o arquivo, remover os marcadores, decidir o conteúdo final
git add <arquivo>
git commit              # se estava em merge
git rebase --continue   # se estava em rebase
git merge --abort        # cancela e volta ao estado anterior
git rebase --abort        # idem, para rebase
```

## Fluxos de trabalho (workflows)

- **Feature Branch Workflow** (padrão default deste usuário) — cada
  tarefa/feature em uma branch própria, integrada de volta na branch
  principal. Simples, funciona bem com CI/CD.
- **Git Flow** — branches fixas (`main`, `develop`, `feature/*`,
  `release/*`, `hotfix/*`). Bom para releases versionados e espaçados;
  pesado demais para deploy contínuo.
- **Trunk-Based Development** — integração direta (ou branches muito
  curtas) em uma branch única, escondendo trabalho incompleto atrás de
  feature flags. Favorece CI/CD rápido.
- **Forking Workflow** — comum em open source: cada colaborador tem seu
  próprio fork, propõe mudanças via PR entre repositórios.

## Squash / Rebase / Merge no fechamento de um PR

Nas plataformas (GitHub/GitLab), ao fechar um PR:

- **Merge commit** — mantém todos os commits da branch + um commit de
  merge.
- **Squash and merge** — junta todos os commits da branch em um único
  commit sobre a branch principal.
- **Rebase and merge** — reaplica cada commit individualmente, linear, sem
  commit de merge.

Decisão de convenção do time/projeto — squash deixa a branch principal com
um commit por PR; merge commit preserva granularidade.
