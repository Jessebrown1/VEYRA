import { CallHandler, ExecutionContext, Injectable, Logger, NestInterceptor } from '@nestjs/common';
import { Observable } from 'rxjs';
import { tap } from 'rxjs/operators';

/** Logs method/path/duration/status only — never request bodies, tokens, or message content. */
@Injectable()
export class LoggingInterceptor implements NestInterceptor {
  private readonly logger = new Logger('HTTP');

  intercept(context: ExecutionContext, next: CallHandler): Observable<unknown> {
    const req = context.switchToHttp().getRequest();
    const { method, url } = req;
    const start = Date.now();

    return next.handle().pipe(
      tap({
        next: () => {
          this.logger.log(`${method} ${url} ${Date.now() - start}ms`);
        },
        error: (err: { status?: number }) => {
          this.logger.warn(`${method} ${url} ${Date.now() - start}ms ERROR ${err?.status ?? 500}`);
        },
      }),
    );
  }
}
