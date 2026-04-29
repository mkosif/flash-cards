import { relationalStore } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';
import { JSON, util } from '@kit.ArkTS';
import WordData from '../models/WordData';
import { secureRandomNumber } from '../utils/SecureRandom';

const DB_NAME: string = 'WordLists.db';
const DB_VERSION: number = 2;

const STORE_CONFIG: relationalStore.StoreConfig = {
  name: DB_NAME,
  securityLevel: relationalStore.SecurityLevel.S3,
  encrypt: false
};

export interface Remaining {
  learnedCount: number,
  unlearnedCount: number
}

function getSQLCreateTableString(tableName: string) {
  return `CREATE TABLE IF NOT EXISTS ${tableName} (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    article TEXT,
    word TEXT NOT NULL,
    meaning TEXT,
    example TEXT,
    learned INTEGER DEFAULT 0,
    box_level INTEGER DEFAULT 1,
    next_review_date TEXT,
    review_count INTEGER DEFAULT 0,
    correct_count INTEGER DEFAULT 0,
    wrong_count INTEGER DEFAULT 0,
    difficulty_score REAL DEFAULT 50.0,
    last_reviewed TEXT,
    category TEXT
  )`
}

function getSQLCreateIndexStrings(tableName: string): string[] {
  return [
    `CREATE INDEX IF NOT EXISTS idx_${tableName}_learned ON ${tableName} (learned)`,
    `CREATE INDEX IF NOT EXISTS idx_${tableName}_next_review ON ${tableName} (next_review_date)`,
    `CREATE INDEX IF NOT EXISTS idx_${tableName}_category ON ${tableName} (category)`
  ]
}

export interface WordListJson {
  version: string;
  header: Record<string, string>;
  data: WordData[];
}

export interface DatabaseManagerParam {
  databaseManager: DatabaseManager
}

function doRand(): number {
  return secureRandomNumber();
}

export class DatabaseManager {
  private rdbStore?: relationalStore.RdbStore;
  private tableName: string = ''

  public close() {
    try {
      this.rdbStore?.close()
      this.rdbStore = undefined
    } catch (e) {
      console.error(`Database close failed: ${JSON.stringify(e)}`);
    }
  }

  async createStore(context: Context | undefined, tableName: string): Promise<void> {
    return new Promise<void>((resolve, reject) => {

      if (this.rdbStore && this.tableName === tableName) {
        resolve();
        return;
      }
      relationalStore.getRdbStore(context, STORE_CONFIG,
        async (err: BusinessError | undefined, store: relationalStore.RdbStore) => {
          if (err) {
            console.error(`Failed to get RdbStore. Code:${err.code}, message:${err.message}`);
            reject(err);
            return;
          }
          this.rdbStore = store
          this.tableName = tableName
          let storeVersion: number = store.version;

          try {
            const queryResult = await store.querySql(
              `SELECT name FROM sqlite_master WHERE type='table' AND name=?;`,
              [tableName]
            );
            const tableExists = queryResult.rowCount > 0;
            queryResult.close();

            if (!tableExists) {
              await store.execute(getSQLCreateTableString(tableName));
              for (const indexSql of getSQLCreateIndexStrings(tableName)) {
                await store.execute(indexSql);
              }
              await this.importFromJson(context, tableName)

              if (storeVersion === 0) {
                store.version = DB_VERSION;
              }
            } else {
              console.info(`Table ${tableName} already exists. Checking for schema updates.`);
              if (store.version < 2) {
                try {
                   await store.execute(`ALTER TABLE ${tableName} ADD COLUMN box_level INTEGER DEFAULT 1`);
                   await store.execute(`ALTER TABLE ${tableName} ADD COLUMN next_review_date TEXT`);
                   await store.execute(`ALTER TABLE ${tableName} ADD COLUMN review_count INTEGER DEFAULT 0`);
                   await store.execute(`ALTER TABLE ${tableName} ADD COLUMN correct_count INTEGER DEFAULT 0`);
                   await store.execute(`ALTER TABLE ${tableName} ADD COLUMN wrong_count INTEGER DEFAULT 0`);
                   await store.execute(`ALTER TABLE ${tableName} ADD COLUMN difficulty_score REAL DEFAULT 50.0`);
                   await store.execute(`ALTER TABLE ${tableName} ADD COLUMN last_reviewed TEXT`);
                   await store.execute(`ALTER TABLE ${tableName} ADD COLUMN category TEXT`);
                   for (const indexSql of getSQLCreateIndexStrings(tableName)) {
                     await store.execute(indexSql);
                   }
                   store.version = 2;
                } catch (e) {
                   console.error(`Migration failed: ${JSON.stringify(e)}`);
                }
              }
            }
          } catch (e) {
            const error = e as BusinessError;
            console.error(`Failed to handle table setup. Code:${error.code}, message:${error.message}`);
            reject(error);
            return;
          }

          resolve();
        });
    });
  }

  async insertWord(entry: WordData): Promise<void> {
    if (!this.rdbStore) {
      throw new Error('Database not initialized.');
    }

    const values: relationalStore.ValuesBucket = {
      article: entry.article,
      word: entry.word,
      meaning: entry.meaning,
      example: entry.example,
      learned: entry.learned ? 1 : 0,
      box_level: entry.boxLevel,
      next_review_date: entry.nextReviewDate,
      review_count: entry.reviewCount,
      correct_count: entry.correctCount,
      wrong_count: entry.wrongCount,
      difficulty_score: entry.difficultyScore,
      last_reviewed: entry.lastReviewed,
      category: entry.category
    };

    try {
      const rowId: number = await this.rdbStore.insert(this.tableName, values);
      console.info(`Inserted word ${entry.word} (rowId=${rowId})`);
    } catch (error) {
      const err = error as BusinessError;
      console.error(`Failed to insert word. Code:${err.code}, message:${err.message}`);
    }
  }

  async importFromJson(context: Context | undefined, filename: string): Promise<void> {
    const rm = context?.resourceManager;
    if (!rm) {
      console.error('resourceManager is undefined');
      return;
    }

    try {
      const fileData = await rm.getRawFileContent(`rawfile/wordLists/${filename}.json`);
      const decoder = util.TextDecoder.create('utf-8');
      let text = decoder.decodeToString(fileData)

      const wl = JSON.parse(text) as WordListJson;

      if (!wl.data || !Array.isArray(wl.data)) {
        console.error(`JSON missing 'data' array`);
        return;
      }

      for (const entry of wl.data) {
        await this.insertWord(entry);
      }

      console.info(`Imported ${wl.data.length} words.`);
    } catch (e) {
      console.error('JSON import failed:', JSON.stringify(e));
    }
  }

  async getAllWords(): Promise<Array<WordData>> {
    if (!this.rdbStore) {
      throw new Error('Database not initialized.');
    }

    return new Promise<Array<WordData>>((resolve, reject) => {
      const predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates(this.tableName);

      try {
        this.rdbStore!.query(
          predicates,
          [
            'id', 'article', 'word', 'meaning', 'example', 'learned', 'box_level',
            'next_review_date', 'review_count', 'correct_count', 'wrong_count',
            'difficulty_score', 'last_reviewed', 'category'
          ],
          (err: BusinessError | undefined, resultSet: relationalStore.ResultSet) => {
            if (err) {
              console.error(`Query failed. Code:${err.code}, message:${err.message}`);
              reject(err);
              return;
            }

            const results: Array<WordData> = [];

            while (resultSet.goToNextRow()) {
              results.push(new WordData(
                resultSet.getLong(resultSet.getColumnIndex('id')),
                resultSet.getString(resultSet.getColumnIndex('article')),
                resultSet.getString(resultSet.getColumnIndex('word')),
                resultSet.getString(resultSet.getColumnIndex('meaning')),
                resultSet.getString(resultSet.getColumnIndex('example')),
                resultSet.getLong(resultSet.getColumnIndex('learned')) === 1,
                resultSet.getLong(resultSet.getColumnIndex('box_level')),
                resultSet.getString(resultSet.getColumnIndex('next_review_date')),
                resultSet.getLong(resultSet.getColumnIndex('review_count')),
                resultSet.getLong(resultSet.getColumnIndex('correct_count')),
                resultSet.getLong(resultSet.getColumnIndex('wrong_count')),
                resultSet.getDouble(resultSet.getColumnIndex('difficulty_score')),
                resultSet.getString(resultSet.getColumnIndex('last_reviewed')),
                resultSet.getString(resultSet.getColumnIndex('category'))
              )
              );
            }

            resultSet.close();
            resolve(results);
          }
        );
      } catch (e) {
        const error = e as BusinessError;
        reject(error);
      }
    });
  }

  async setLearnedById(id: number): Promise<void> {
    if (!this.rdbStore) {
      throw new Error('Database not initialized.');
    }

    const values: relationalStore.ValuesBucket = {
      learned: 1
    };

    const predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates(this.tableName);
    predicates.equalTo('id', id);

    try {
      const rowsAffected: number = await this.rdbStore.update(values, predicates);
      if (rowsAffected > 0) {
        console.info(`Updated word with id=${id} to learned=true. Rows affected: ${rowsAffected}`);
      } else {
        console.warn(`No word found with id=${id} to update.`);
      }
    } catch (error) {
      const err = error as BusinessError;
      console.error(`Failed to update word. Code:${err.code}, message:${err.message}`);
    }
  }
 
  async updateWordProgress(
    id: number,
    boxLevel: number,
    nextReviewDate: string,
    reviewCount: number,
    correctCount: number,
    wrongCount: number,
    difficultyScore: number,
    lastReviewed: string,
    learned: boolean
  ): Promise<void> {
    if (!this.rdbStore) {
      throw new Error('Database not initialized.');
    }

    const values: relationalStore.ValuesBucket = {
      box_level: boxLevel,
      next_review_date: nextReviewDate,
      review_count: reviewCount,
      correct_count: correctCount,
      wrong_count: wrongCount,
      difficulty_score: difficultyScore,
      last_reviewed: lastReviewed,
      learned: learned ? 1 : 0
    };

    const predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates(this.tableName);
    predicates.equalTo('id', id);

    try {
      await this.rdbStore.update(values, predicates);
    } catch (error) {
      const err = error as BusinessError;
      console.error(`Failed to update word progress. Code:${err.code}, message:${err.message}`);
    }
  }

  async getRandomUnlearnedWord(requiredCount: number, excludedIds: number[] = []): Promise<WordData[] | null> {
    if (!this.rdbStore) {
      throw new Error('Database not initialized.');
    }

    const rdbStore = this.rdbStore;
    const tableName = this.tableName;

    try {
      const countPredicates = new relationalStore.RdbPredicates(tableName);
      countPredicates.equalTo('learned', 0);
      if (excludedIds.length > 0) {
        countPredicates.notIn('id', excludedIds);
      }

      const countResult = await rdbStore.query(countPredicates, ['COUNT(*)']);
      countResult.goToFirstRow();
      const totalUnlearned = countResult.getLong(0);
      countResult.close();

      if (totalUnlearned === 0) {
        return null;
      }

      const N = Math.min(requiredCount, totalUnlearned);
      const offsets = new Set<number>();
      while (offsets.size < N) {
        const r = doRand();
        offsets.add(Math.floor(r * totalUnlearned));
      }

      const results: WordData[] = [];
      for (const offset of Array.from(offsets)) {
        const wordPred = new relationalStore.RdbPredicates(tableName);
        wordPred.equalTo('learned', 0);
        if (excludedIds.length > 0) {
          wordPred.notIn('id', excludedIds);
        }
        wordPred.limitAs(1);
        wordPred.offsetAs(offset);

        const rs = await rdbStore.query(
          wordPred,
          [
            'id', 'article', 'word', 'meaning', 'example', 'learned',
            'box_level', 'next_review_date', 'review_count', 'correct_count',
            'wrong_count', 'difficulty_score', 'last_reviewed', 'category'
          ]
        );

        if (rs.goToFirstRow()) {
          results.push(new WordData(
            rs.getLong(rs.getColumnIndex('id')),
            rs.getString(rs.getColumnIndex('article')),
            rs.getString(rs.getColumnIndex('word')),
            rs.getString(rs.getColumnIndex('meaning')),
            rs.getString(rs.getColumnIndex('example')),
            rs.getLong(rs.getColumnIndex('learned')) === 1,
            rs.getLong(rs.getColumnIndex('box_level')),
            rs.getString(rs.getColumnIndex('next_review_date')),
            rs.getLong(rs.getColumnIndex('review_count')),
            rs.getLong(rs.getColumnIndex('correct_count')),
            rs.getLong(rs.getColumnIndex('wrong_count')),
            rs.getDouble(rs.getColumnIndex('difficulty_score')),
            rs.getString(rs.getColumnIndex('last_reviewed')),
            rs.getString(rs.getColumnIndex('category'))
          ));
        }
        rs.close();
      }
      return results;
    } catch (e) {
      console.error(`getRandomUnlearnedWord failed: ${JSON.stringify(e)}`);
      return null;
    }
  }

  async getDueWords(): Promise<WordData[]> {
    if (!this.rdbStore) {
      throw new Error('Database not initialized.');
    }
    try {
      const now = new Date().toISOString().split('T')[0];
      const predicates = new relationalStore.RdbPredicates(this.tableName);
      predicates.equalTo('learned', 0)
        .and().beginWrap()
        .isNull('next_review_date').or().equalTo('next_review_date', '').or().lessThanOrEqualTo('next_review_date', now)
        .endWrap();

      const resultSet = await this.rdbStore.query(
        predicates,
        [
          'id', 'article', 'word', 'meaning', 'example', 'learned', 'box_level',
          'next_review_date', 'review_count', 'correct_count', 'wrong_count',
          'difficulty_score', 'last_reviewed', 'category'
        ]
      );
      const results: WordData[] = [];
      while (resultSet.goToNextRow()) {
        results.push(new WordData(
          resultSet.getLong(resultSet.getColumnIndex('id')),
          resultSet.getString(resultSet.getColumnIndex('article')),
          resultSet.getString(resultSet.getColumnIndex('word')),
          resultSet.getString(resultSet.getColumnIndex('meaning')),
          resultSet.getString(resultSet.getColumnIndex('example')),
          resultSet.getLong(resultSet.getColumnIndex('learned')) === 1,
          resultSet.getLong(resultSet.getColumnIndex('box_level')),
          resultSet.getString(resultSet.getColumnIndex('next_review_date')),
          resultSet.getLong(resultSet.getColumnIndex('review_count')),
          resultSet.getLong(resultSet.getColumnIndex('correct_count')),
          resultSet.getLong(resultSet.getColumnIndex('wrong_count')),
          resultSet.getDouble(resultSet.getColumnIndex('difficulty_score')),
          resultSet.getString(resultSet.getColumnIndex('last_reviewed')),
          resultSet.getString(resultSet.getColumnIndex('category'))
        ));
      }
      resultSet.close();
      return results;
    } catch (e) {
      console.error(`getDueWords failed: ${JSON.stringify(e)}`);
      return [];
    }
  }

  async getWordCounts(): Promise<Remaining> {
    if (!this.rdbStore) {
      throw new Error('Database not initialized.');
    }

    try {
      const learnedPred = new relationalStore.RdbPredicates(this.tableName);
      learnedPred.equalTo('learned', 1);
      const learnedResult = await this.rdbStore.query(learnedPred, ['COUNT(*)']);
      learnedResult.goToFirstRow();
      const learnedCount = learnedResult.getLong(0);
      learnedResult.close();

      const unlearnedPred = new relationalStore.RdbPredicates(this.tableName);
      unlearnedPred.equalTo('learned', 0);
      const unlearnedResult = await this.rdbStore.query(unlearnedPred, ['COUNT(*)']);
      unlearnedResult.goToFirstRow();
      const unlearnedCount = unlearnedResult.getLong(0);
      unlearnedResult.close();

      return { learnedCount, unlearnedCount };
    } catch (e) {
      console.error(`getWordCounts failed: ${JSON.stringify(e)}`);
      return { learnedCount: 0, unlearnedCount: 0 };
    }
  }

  async setAllUnlearned(): Promise<void> {
    if (!this.rdbStore) {
      throw new Error('Database not initialized.');
    }
    const values: relationalStore.ValuesBucket = {
      learned: 0,
      box_level: 1,
      review_count: 0,
      correct_count: 0,
      wrong_count: 0,
      difficulty_score: 50.0,
      last_reviewed: '',
      next_review_date: ''
    };
    const predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates(this.tableName);
    try {
      const rowsAffected: number = await this.rdbStore.update(values, predicates);
      console.info(`Reset learned status for table ${this.tableName}. Rows affected: ${rowsAffected}`);
    } catch (error) {
      const err = error as BusinessError;
      console.error(`Failed to reset learned status. Code:${err.code}, message:${err.message}`);
    }
  }
}
