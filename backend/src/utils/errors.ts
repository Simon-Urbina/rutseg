export class AppError extends Error {
  constructor(message: string) {
    super(message)
    this.name = this.constructor.name
  }
}

export class NotFoundError extends AppError {}
export class ForbiddenError extends AppError {}
export class ConflictError extends AppError {}
export class UnauthorizedError extends AppError {}
export class BadRequestError extends AppError {}

export class ValidationError extends AppError {
  constructor(public readonly errors: string[]) {
    super(errors.join(' | '))
  }
}
