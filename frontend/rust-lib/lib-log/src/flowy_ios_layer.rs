include!(concat!(env!("OUT_DIR"), "/os_log_bindings.rs"));

use tracing::{Event, Subscriber};
use tracing_subscriber::Layer;

// iOS os_log apis

pub struct OsLogLayer;

impl<S: Subscriber> Layer<S> for OsLogLayer
where
  S: tracing::Subscriber,
{
  fn on_event(&self, event: &Event<'_>, _ctx: tracing_subscriber::layer::Context<'_, S>) {
    println!("Got event!");
    println!("  level={:?}", event.metadata().level());
    println!("  target={:?}", event.metadata().target());
    println!("  name={:?}", event.metadata().name());
    for field in event.fields() {
      println!("  field={}", field.name());
    }
  }
}
