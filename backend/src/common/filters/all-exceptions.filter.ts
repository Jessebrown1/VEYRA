import { ArgumentsHost, Catch, ExceptionFilter, HttpException, HttpStatus, Logger } from '@nestjs/common';
import { Response } from 'express';

@Catch()
export class AllExceptionsFilter implements ExceptionFilter {
  private readonly logger = new Logger('ExceptionFilter');

  catch(exception: unknown, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();

    let status = HttpStatus.INTERNAL_SERVER_ERROR;
    let code = 'INTERNAL_ERROR';
    let message = 'Something went wrong. Please try again.';

    if (exception instanceof HttpException) {
      status = exception.getStatus();
      code = HttpStatus[status] ?? 'ERROR';
      const body = exception.getResponse();
      if (typeof body === 'string') {
        message = body;
      } else if (typeof body === 'object' && body !== null) {
        const anyBody = body as Record<string, unknown>;
        if (Array.isArray(anyBody.message)) {
          message = anyBody.message.join(', ');
        } else if (typeof anyBody.message === 'string') {
          message = anyBody.message;
        }
        if (typeof anyBody.code === 'string') {
          code = anyBody.code;
        }
      }
    } else {
      // Never leak stack traces or internals to the client — log server-side only.
      this.logger.error(exception instanceof Error ? exception.stack : exception);
    }

    response.status(status).json({ error: { code, message } });
  }
}
