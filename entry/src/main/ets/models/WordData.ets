export default class WordData {
  id: number = 0
  article: string = '';
  word: string = '';
  meaning: string = '';
  example: string = '';
  learned: boolean = false
  boxLevel: number = 1
  nextReviewDate: string = ''
  reviewCount: number = 0
  correctCount: number = 0
  wrongCount: number = 0
  difficultyScore: number = 50.0
  lastReviewed: string = ''
  category: string = ''
  imageSrc: string = ''

  constructor(
    id: number,
    article: string,
    word: string,
    meaning: string,
    example: string,
    learned: boolean,
    boxLevel: number = 1,
    nextReviewDate: string = '',
    reviewCount: number = 0,
    correctCount: number = 0,
    wrongCount: number = 0,
    difficultyScore: number = 50.0,
    lastReviewed: string = '',
    category: string = '',
    imageSrc: string = ''
  ) {
    this.id = id
    this.article = article
    this.word = word
    this.meaning = meaning
    this.example = example
    this.learned = learned
    this.boxLevel = boxLevel
    this.nextReviewDate = nextReviewDate
    this.reviewCount = reviewCount
    this.correctCount = correctCount
    this.wrongCount = wrongCount
    this.difficultyScore = difficultyScore
    this.lastReviewed = lastReviewed
    this.category = category
    this.imageSrc = imageSrc
  }

  public toString() {
    return [
      `{ id: ${this.id}, ${this.article} ${this.word}, meaning: ${this.meaning}, `,
      `example: ${this.example}, learned: ${this.learned}, boxLevel: ${this.boxLevel}, `,
      `nextReview: ${this.nextReviewDate} }`
    ].join('')
  }
}
