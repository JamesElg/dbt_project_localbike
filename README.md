# Local Bike — Projet Analytics Engineering

Cas Final DataBird — modélisation dbt + BigQuery pour l'équipe opérations de Local Bike (Alexander Anthony), à partir du dataset OLTP `sales_database` (domaines Sales et Production).

## Contexte et objectif

Local Bike veut son premier tableau de bord et se lancer dans l'exploitation de données. Ce projet modélise les données pour répondre à une question décisionnelle unique :

> **Où l'équipe opérations doit-elle concentrer ses actions en priorité — sur la performance par magasin, l'assortiment produit, ou la relation commerciale (clients et équipe de vente) — pour maximiser le revenu de Local Bike ?**

Trois leviers structurent l'ensemble du projet :

1. **Performance par magasin** — revenu, volume, panier moyen par point de vente
2. **Performance de l'assortiment produit** — revenu et remises par catégorie/marque, avec le stock comme signal contextuel (non historisé)
3. **Relation commerciale** — fidélisation client et performance des vendeurs (comparés uniquement au sein d'un même magasin)

## Architecture des données

- **Source** : dataset BigQuery `sales_database`, chargé manuellement (prototype pédagogique) — 8 tables brutes : `customers`, `staffs`, `orders`, `order_items`, `stores`, `categories`, `products`, `stocks`, `brands`.
- **Couches dbt** : `staging` → `intermediate` → `mart`, conformément au playbook méthodologique du projet.
- **Convention de nommage** : `stg_<source>__<table>`, `int_<source>__<objet>`, `mrt_<sujet>_<grain>`.
- **Approche de modélisation** : dimensionnelle, un fait de vente au grain de la ligne de commande (`order_item`).

## Structure du repo

```
models/
├── staging/
│   ├── sources.yml
│   ├── stg_sales_database__store.sql
│   ├── stg_sales_database__category.sql
│   ├── stg_sales_database__brand.sql
│   ├── stg_sales_database__customer.sql
│   ├── stg_sales_database__staff.sql
│   ├── stg_sales_database__product.sql
│   ├── stg_sales_database__stock.sql
│   ├── stg_sales_database__order.sql
│   ├── stg_sales_database__order_item.sql
│   └── _stg_sales_database__schema.yml
├── intermediate/
│   ├── int_sales_database__order_item.sql
│   └── _int_sales_database__order_item.yml
└── mart/
    ├── mrt_store_performance.sql / _mrt_store_performance.yml
    ├── mrt_product_performance.sql / _mrt_product_performance.yml
    ├── mrt_product_current_stock.sql / _mrt_product_current_stock.yml
    ├── mrt_staff_performance.sql / _mrt_staff_performance.yml
    └── mrt_customer_loyalty.sql / _mrt_customer_loyalty.yml

tests/
├── assert_product_list_price_is_positive.sql
├── assert_stock_quantity_is_non_negative.sql
├── assert_order_dates_are_chronological.sql
├── assert_order_item_quantity_is_positive.sql
└── assert_order_item_revenue_is_non_negative.sql

dbt_project.yml
```

## Modèles — résumé

| Modèle | Couche | Grain | Rôle |
|---|---|---|---|
| `stg_sales_database__*` (x9) | staging | 1 ligne source = 1 ligne | Renommage, typage, clé primaire garantie — aucune jointure |
| `int_sales_database__order_item` | intermediate | 1 ligne de commande | Calcule `order_item_revenue_amount` et le flag `is_completed_order` — source de vérité unique pour le revenu |
| `mrt_store_performance` | mart | magasin × mois | Revenu, panier moyen, nombre de commandes par magasin |
| `mrt_product_performance` | mart | produit × mois | Revenu et taux de remise par produit (rollup possible par catégorie/marque) |
| `mrt_product_current_stock` | mart | produit (snapshot) | Stock actuel par produit, tous magasins confondus — non historisé, volontairement sans dimension mensuelle |
| `mrt_staff_performance` | mart | vendeur × mois | Revenu et nombre de commandes par vendeur — à comparer uniquement au sein d'un même magasin |
| `mrt_customer_loyalty` | mart | client (cumulé) | Nombre de commandes, revenu, statut de fidélisation par client |

## Prérequis

- Python 3.x
- `dbt-core` et l'adaptateur `dbt-bigquery` (versions compatibles avec votre environnement)
- Un accès BigQuery (compte de service ou OAuth) au projet GCP cible et au dataset source `sales_database`

## Installation

```bash
git clone https://github.com/JamesElg/dbt_project_localbike.git
cd dbt_project_localbike
python -m venv venv && source venv/bin/activate
pip install dbt-bigquery
```

## Configuration (`~/.dbt/profiles.yml`)

```yaml
localbike:
  target: dev
  outputs:
    dev:
      type: bigquery
      method: oauth          # ou service-account, selon votre configuration
      project: <votre-projet-gcp>
      dataset: dbt_dev       # schéma de développement — distinct du dataset source
      location: <votre-location>   # ex. US, EU
      threads: 4
```

> `sales_database` est le dataset **source** (déclaré dans `models/staging/sources.yml`) — ne pas le confondre avec le dataset de sortie des modèles dbt (`dbt_dev` ci-dessus, ou son équivalent en production).

## Exécution

```bash
dbt debug              # vérifie la connexion à BigQuery
dbt build               # construit et teste tous les modèles, dans l'ordre du graphe
dbt test                # rejoue les tests seuls si besoin
dbt docs generate && dbt docs serve   # documentation technique générée depuis les schema.yml
```

## Règles de gestion à connaître avant de lire le SQL

- **`order_status = 4`** = commande complétée/livrée (seul statut avec `shipped_date` renseignée dans la source, qui ne fournit aucune légende officielle). C'est la seule population comptée dans le revenu officiel (`is_completed_order`, calculé dans `int_sales_database__order_item`).
- **`mrt_customer_loyalty`** compte **toutes** les commandes (quel que soit leur statut) pour `total_order_count` et `is_repeat_customer` — la fidélisation est un signal d'engagement, pas une mesure de revenu — alors que `total_revenue_amount`, dans ce même mart, reste restreint aux commandes complétées.
- **Le stock** (`mrt_product_current_stock`) est une photo à un instant T, non historisée dans la source : il n'existe volontairement aucun grain "stock par mois" dans ce projet.
- **`mrt_staff_performance`** ne doit être lu qu'en comparant des vendeurs d'un **même magasin** (`store_id`) : le volume brut par vendeur est fortement corrélé au volume du magasin, pas à la performance individuelle.

## Limites connues (documentées, non masquées)

- Les vendeurs `staff_id` 4 et 10 (sur 10 au total) n'apparaissent jamais dans les données de commande, sans explication dans la source — ce ne sont pas des managers (contrairement à `staff_id` 1 et 5, qui n'ont logiquement pas de commande à leur nom).
- Les codes `order_status` ne sont pas légendés officiellement ; l'interprétation retenue (4 = livré) repose sur une corrélation observée avec `shipped_date`, pas sur une documentation source.
- Le déséquilibre de volume entre magasins (Baldwin ≫ Santa Cruz > Rowlett) n'a pas été investigué au-delà de sa corrélation avec la répartition géographique de la base clients.
- `customers.phone` est manquant pour 87,7 % des clients — non utilisé par aucun KPI du projet.

## Prochaines étapes

- Visualisation dans l'outil de BI choisi (Metabase / Power BI / Tableau)
- Peer review sur GitHub
- (Bonus) Dashboard complet répondant à la problématique d'optimisation du revenu

## Origine des données

Dataset pédagogique fourni dans le cadre du cursus Analytics Engineer (DataBird), cas "Local Bike".